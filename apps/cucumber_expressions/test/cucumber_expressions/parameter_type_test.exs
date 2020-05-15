defmodule CucumberExpressions.ParameterTypeTest do
  @moduledoc false
  use ExUnit.Case

  alias CucumberExpressions.ParameterType

  defmodule A do
    def run(_, _) do
    end
  end

  describe "" do
    test "" do
      ParameterType.new()
      |> ParameterType.add(%{name: :int, type: :integer, validator: {A, :run}})
    end
  end
end
