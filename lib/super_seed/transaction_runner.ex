defmodule SuperSeed.TransactionRunner do
  use GenServer
  require Logger
  alias SuperSeed.TransactionRunnerException

  def start_link(server_pid, inserter_module, timeout) do
    GenServer.start_link(__MODULE__, {server_pid, inserter_module, timeout})
  end

  @impl true
  def init({server_pid, inserter_module, timeout}) do
    Logger.debug("TransactionRunner #{inserter_module} #{inspect(self())} - Starting")

    {:ok,
     %{
       server_pid: server_pid,
       inserter_module: inserter_module,
       status: :pending,
       start_time: nil,
       timeout: timeout
     }}
  end

  @impl true
  def handle_cast({:run, results}, state) do
    Logger.debug("TransactionRunner #{state.inserter_module} #{inspect(self())} - Running")

    if state.status == :pending do
      {:noreply, %{state | status: :running, start_time: DateTime.utc_now()},
       {:continue, {:run, results}}}
    else
      {:noreply, state}
    end
  end

  @impl true
  def handle_continue({:run, results}, state) do
    {:ok, result} =
      Repo.transaction(fn -> state.inserter_module.insert(results) end, timeout: state.timeout)

    state = Map.put(state, :result, result)
    {:stop, :normal, state}
  end

  @impl true
  def terminate(:normal, state) do
    elapsed_time_in_ms = DateTime.diff(DateTime.utc_now(), state.start_time, :millisecond)

    Logger.debug(
      "TransactionRunner #{state.inserter_module} #{inspect(self())} - Finished in #{elapsed_time_in_ms}ms"
    )

    GenServer.cast(state.server_pid, {:inserter_finished, self(), state.result})
  end

  def terminate({exception, stacktrace}, _state) when is_exception(exception) do
    reraise exception, stacktrace
  end

  def terminate(other, _state) do
    raise(TransactionRunnerException, other)
  end
end
