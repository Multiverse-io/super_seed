defmodule SuperSeed.InserterModulesTest do
  use ExUnit.Case, async: true
  use Mimic
  alias SuperSeed.{Checks, InserterModules}

  describe "find/1" do
    test "only returns modules with the given namespace" do
      Mimic.expect(Checks, :code_all_loaded, fn ->
        [
          {Apples.One, "file_1"},
          {Apples.Two, "file_2"},
          {Pears.Three, "file_3"},
          {Pears.Four, "file_4"}
        ]
      end)

      assert InserterModules.find(Apples) == [Apples.One, Apples.Two]
    end

    test "only returns modules with the given namespace when they are deeply named" do
      Mimic.expect(Checks, :code_all_loaded, fn ->
        [
          {Apples.A.B.C.D.One, "file_1"},
          {Apples.A.B.C.E.Two, "file_2"},
          {Pears.W.X.Y.Z.Three, "file_3"},
          {Pears.W.X.Y.Z.Four, "file_4"}
        ]
      end)

      assert InserterModules.find(Apples.A.B.C.D) == [Apples.A.B.C.D.One]
    end

    test "modules with Elixir at the start are also included" do
      Mimic.expect(Checks, :code_all_loaded, fn ->
        [
          {Apples.One, "file_1"},
          {Apples.Two, "file_2"},
          {Elixir.Apples.Three, "file_3"},
          {Elixir.Apples.Four, "file_4"}
        ]
      end)

      assert InserterModules.find(Apples) == [
               Apples.One,
               Apples.Two,
               Elixir.Apples.Three,
               Elixir.Apples.Four
             ]
    end

    test "returns nothing when there're no modules" do
      Mimic.expect(Checks, :code_all_loaded, fn ->
        []
      end)

      assert InserterModules.find(Apples) == []
    end
  end
end
