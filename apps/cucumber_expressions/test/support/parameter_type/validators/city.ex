defmodule Support.ParameterType.Validator.City do
  @valid_cities ["Toronto", "Istanbul"]

  def new(%Support.ParameterType.Transformer.City{} = city) do
    if city.value in @valid_cities do
      {:ok, city}
    else
      {:error, {:invalid_city, city}}
    end
  end

  def new(city), do: {:error, {:incorrect_struct, city}}

  def run(str, _), do: new(str)
end
