defmodule CucumberExpressions.ParameterType.Canonical.Float do
  @moduledoc false
  @regex ~r/^[+-]?([0-9]*[.])?[0-9]+$/
  alias CucumberExpressions.ParameterType.Canonical.Int

  def meta,
    do: %{
      name: :float,
      type: :float,
      disambiguator: @regex,
      transformer: {__MODULE__, :transform}
    }

  def transform(str, _) do
    str
    |> String.split(".")
    |> case do
      [int] ->
        Int.parse(int)

      [_, _] ->
        parse(str)

      _ ->
        raise "Multiple dots are impossible. Disambiguator should have singled out a simple float. Instead: #{inspect(str)}"
    end
    |> case do
      {:ok, _} = ok ->
        ok

      :error ->
        raise "This is impossible. Disambiguator should have singled out a simple float. Instead: #{inspect(str)}"
    end
  end

  def parse(str) do
    str
    |> Float.parse()
    |> case do
      {float, ""} -> {:ok, float}
      _ -> :error
    end
  end
end
