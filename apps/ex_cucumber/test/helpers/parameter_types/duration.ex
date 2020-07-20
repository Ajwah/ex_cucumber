defmodule Support.ParameterTypes.Duration do
  @behaviour ExCucumber.CustomParameterType

  defstruct raw: :none,
            value: :none,
            hours: 0

  alias Support.ParameterTypes.Validator.Integer, as: IntegerValidator
  @regex ~r/^(?<hours>\d{1,2}) hours$/

  @impl true
  def validator(str, ctx), do: run(str, ctx)

  def run(str, _) do
    c = Regex.named_captures(@regex, str)

    with {_, _, {hours, true}} <- validate_hours(c["hours"]) do
      {:ok,
       struct(__MODULE__, %{
         raw: str,
         value: str,
         hours: hours
       })}
    else
      {msg, error_code, _} -> {:error, error_code, msg}
    end
  end

  defp validate_hours(hours) do
    hours
    |> IntegerValidator.run()
    |> case do
      {:error, :not_integer, _} ->
        {"Invalid hours: #{hours}", :invalid_hours, {hours, false}}

      {:ok, hours} ->
        if hours > 1 && hours <= 32 do
          {"", :valid_hours, {hours, true}}
        else
          {"hours out of range: #{hours}", :out_of_range_hours, {hours, false}}
        end
    end
  end
end
