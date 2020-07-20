defmodule Support.ParameterTypes.Date do
  @behaviour ExCucumber.CustomParameterType

  defstruct raw: :none,
            value: :none,
            month: "",
            year: "",
            day: 0,
            day_name: ""

  alias Support.ParameterTypes.Validator.Integer, as: IntegerValidator

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
  @valid_day_names ["monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday"]
  @regex ~r/^(?<day_name>\b.*\b), (?<day>\d{1,2}) (?<month>\b.*\b) (?<year>\d{4})$/

  @impl true
  def validator(str, ctx), do: run(str, ctx)

  def run(str, _) do
    c = Regex.named_captures(@regex, str)

    with {_, _, {month, true}} <- validate_month(c["month"]),
         {_, _, {year, true}} <- validate_year(c["year"]),
         {_, _, {day_name, true}} <- validate_day_name(c["day_name"]),
         {_, _, {day, true}} <- validate_day(c["day"], month, year) do
      {:ok,
       struct(__MODULE__, %{
         raw: str,
         value: str,
         month: month,
         year: year,
         day: day,
         day_name: day_name
       })}
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

  defp validate_day_name(day_name) do
    day_name = String.downcase(day_name)

    if day_name in @valid_day_names do
      {"", :valid_day_name, {String.capitalize(day_name), true}}
    else
      {"Invalid day_name: #{day_name}", :invalid_day_name, {day_name, false}}
    end
  end

  defp validate_year(year) do
    year
    |> IntegerValidator.run()
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
    |> IntegerValidator.run()
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
end
