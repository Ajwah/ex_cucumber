defmodule Support.ParameterTypes.City.Transformer do
  defstruct value: :none, raw: :none

  def new(city) do
    {:ok, struct(__MODULE__, %{value: capitalize_per_word(city), raw: city})}
  end

  defp capitalize_per_word(string) do
    String.split(string)
    |> Enum.map(&String.capitalize/1)
    |> Enum.join(" ")
  end
end
