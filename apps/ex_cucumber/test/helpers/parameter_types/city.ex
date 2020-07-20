defmodule Support.ParameterTypes.City do
  @behaviour ExCucumber.CustomParameterType

  @impl true
  def pre_transformer(str, _), do: __MODULE__.Transformer.new(str)

  @impl true
  def validator(str, _), do: __MODULE__.Validator.new(str)
end
