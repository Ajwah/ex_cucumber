defmodule CucumberExpressions.ParameterType.Canonical.Int do
  @moduledoc false
  @regex ~r/^[+-]?\d+$/

  def meta,
    do: %{name: :int, type: :int, disambiguator: @regex, transformer: {__MODULE__, :transform}}

  def transform(str, _) do
    str
    |> parse
    |> case do
      {:ok, _} = ok ->
        ok

      :error ->
        raise "This is impossible. Disambiguator should have singled out only digits. Instead: #{inspect(str)}"
    end
  end

  def parse(str) do
    str
    |> Integer.parse()
    |> case do
      {int, ""} -> {:ok, int}
      _ -> :error
    end
  end
end
