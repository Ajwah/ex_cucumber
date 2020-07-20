defmodule Support.ParameterTypes.Price do
  @behaviour ExCucumber.CustomParameterType

  defstruct raw: :none,
            value: :none,
            amount: 0,
            unit: :none

  alias Support.ParameterTypes.Validator.Integer, as: IntegerValidator
  @valid_units [:cad, :usd]

  @regex ~r/^(?<amount>\d+) (?<unit>[A-Z]{3})$/
  @impl true
  def validator(str, ctx), do: run(str, ctx)

  def run(str, _) do
    c = Regex.named_captures(@regex, str)

    with {_, _, {amount, true}} <- validate_amount(c["amount"]),
         {_, _, {unit, true}} <- validate_unit(c["unit"]) do
      {:ok,
       struct(__MODULE__, %{
         raw: str,
         value: str,
         amount: amount,
         unit: unit
       })}
    else
      {msg, error_code, _} -> {:error, error_code, msg}
    end
  end

  defp validate_amount(amount) do
    amount
    |> IntegerValidator.run()
    |> case do
      {:error, :not_integer, _} ->
        {"Invalid amount: #{amount}", :invalid_amount, {amount, false}}

      {:ok, amount} ->
        if amount >= 100 && amount <= 20_000 do
          {"", :valid_amount, {amount, true}}
        else
          {"amount out of range: #{amount}", :out_of_range_amount, {amount, false}}
        end
    end
  end

  defp validate_unit(original_unit) do
    unit =
      original_unit
      |> String.downcase()
      |> String.to_atom()

    if unit in @valid_units do
      {"", :valid_unit, {unit, true}}
    else
      {"Invalid unit: #{unit}", :invalid_unit, {original_unit, false}}
    end
  end
end
