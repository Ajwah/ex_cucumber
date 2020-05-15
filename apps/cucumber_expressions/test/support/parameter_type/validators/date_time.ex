defmodule Support.ParameterType.Validator.DateTime do
  defstruct value: :none

  @valid_months [
    "january",
    "february",
    "march",
    "april",
    "may",
    "june",
    "july",
    "august",
    "september",
    "october",
    "november",
    "december"
  ]
  @regex ~r/^(?<day>\d{1,2}) (?<month>[A-Za-z]*) (?<year>\d{4}) at (?<hour>\d{1,2}):(?<minutes>\d{1,2})$/
  def run(str, _) do
    c = Regex.named_captures(@regex, str)

    with {_, _, {month, true}} <- validate_month(c["month"]),
         {_, _, {year, true}} <- validate_year(c["year"]),
         {_, _, {_day, true}} <- validate_day(c["day"], month, year),
         {_, _, {_hour, true}} <- validate_hour(c["hour"]),
         {_, _, {_minutes, true}} <- validate_minutes(c["minutes"]) do
      {:ok, struct(__MODULE__, %{value: str})}
    else
      {msg, error_code, _} -> {:error, error_code, msg}
    end
  end

  defp validate_month(month) do
    month = String.downcase(month)

    if month in @valid_months do
      {"", :valid_month, {String.capitalize(month), true}}
    else
      {"Invalid month: #{month}", :invalid_month, {month, false}}
    end
  end

  defp validate_year(year) do
    year
    |> Support.ParameterType.Validator.Integer.run()
    |> case do
      {:error, :not_integer, _} ->
        {"Invalid year: #{year}", :invalid_year, {year, false}}

      {:ok, year} ->
        if year >= 2010 && year <= 2030 do
          {"", :valid_year, {year, true}}
        else
          {"Year out of range: #{year}", :out_of_range_year, {year, false}}
        end
    end
  end

  # month and year would allow validation with greater fine granularity if need be
  defp validate_day(day, _, _) do
    day
    |> Support.ParameterType.Validator.Integer.run()
    |> case do
      {:error, :not_integer, _} ->
        {"Invalid day: #{day}", :invalid_day, {day, false}}

      {:ok, day} ->
        if day >= 1 && day <= 31 do
          {"", :valid_day, {day, true}}
        else
          {"day out of range: #{day}", :out_of_range_day, {day, false}}
        end
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
