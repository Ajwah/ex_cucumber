defmodule Support.ParameterType.Transformer.City do
  defstruct value: :none, raw: :none

  def new(city) do
    {:ok, struct(__MODULE__, %{value: String.capitalize(city), raw: city})}
  end

  def run(str, _), do: new(str)
end
