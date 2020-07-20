defmodule Support.ParameterTypes.City.Validator do
  @valid_cities ["New York", "Istanbul"]

  def new(%Support.ParameterTypes.City.Transformer{} = transformer) do
    if transformer.value in @valid_cities do
      {:ok, transformer}
    else
      {:error, {:invalid_city, transformer.value}}
    end
  end

  def new(transformer), do: {:error, {:incorrect_struct, transformer}}
end
