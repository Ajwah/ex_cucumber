defmodule Support.ParameterType.Validator.Time do
  defstruct raw: :none,
            value: :none,
            hour: 0,
            minutes: 0

  @regex ~r/^(?<hour>\d{1,2}):(?<minutes>\d{1,2})$/
  def run(str, _) do
    c = Regex.named_captures(@regex, str)

    with {_, _, {hour, true}} <- validate_hour(c["hour"]),
         {_, _, {minutes, true}} <- validate_minutes(c["minutes"]) do
      {:ok,
       struct(__MODULE__, %{
         raw: str,
         value: str,
         hour: hour,
         minutes: minutes
       })}
    else
      {msg, error_code, _} -> {:error, error_code, msg}
    end
  end

  defp validate_hour(hour) do
    hour
    |> Support.ParameterType.Validator.Integer.run()
    |> case do
      {:error, :not_integer, _} ->
        {"Invalid hour: #{hour}", :invalid_hour, {hour, false}}

      {:ok, hour} ->
        if hour >= 0 && hour <= 23 do
          {"", :valid_hour, {hour, true}}
        else
          {"hour out of range: #{hour}", :out_of_range_hour, {hour, false}}
        end
    end
  end

  defp validate_minutes(minutes) do
    minutes
    |> Support.ParameterType.Validator.Integer.run()
    |> case do
      {:error, :not_integer, _} ->
        {"Invalid minutes: #{minutes}", :invalid_minutes, {minutes, false}}

      {:ok, minutes} ->
        if minutes >= 0 && minutes <= 59 do
          {"", :valid_minutes, {minutes, true}}
        else
          {"minutes out of range: #{minutes}", :out_of_range_minutes, {minutes, false}}
        end
    end
  end
end
