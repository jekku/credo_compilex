defmodule CredoCompilex.Checks.FunctionCallOnCompileTest do
  use Credo.Test.Case

  alias CredoCompilex.Checks.FunctionCallOnCompile, as: Check

  test "Finds module attributes that are assigned a value from a function call" do
    """
      defmodule Module do
        @test_attribute OtherModule.call()
      end
    """
    |> to_source_file()
    |> run_check(Check)
    |> assert_issue()

    """
    defmodule Module do
      @module Module
      @call_above @module.call()
    end
    """
    |> to_source_file()
    |> run_check(Check)
    |> assert_issue()

    """
    defmodule Module do
      @test_attribute OtherModule.call(500, "args")
    end
    """
    |> to_source_file()
    |> run_check(Check)
    |> assert_issue()
  end

  test "Can find calls inside common data structures" do
    """
    defmodule Module do
      @test_attribute [OtherModule.call(500, "args"), OtherModule.fun()]
    end
    """
    |> to_source_file()
    |> run_check(Check)
    |> assert_issue()
  end

  test "Clean modules are OK" do
    """
    defmodule Module do
      @attribute :not_a_function
      @attribute "This is not a function"
    end
    """
    |> to_source_file()
    |> run_check(Check)
    |> refute_issues()
  end
end
