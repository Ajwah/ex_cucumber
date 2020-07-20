defmodule Support.ParameterTypes.Flight do
  @behaviour ExCucumber.CustomParameterType

  @impl true
  def validator, do: ~r/[A-Z]{3}-[A-Z]{3}/
end
