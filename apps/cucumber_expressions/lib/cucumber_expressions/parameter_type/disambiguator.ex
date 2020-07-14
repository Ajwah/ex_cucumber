defmodule CucumberExpressions.ParameterType.Disambiguator do
  @moduledoc false

  alias CucumberExpressions.ParameterType.SyntaxError
  use ExDebugger.Manual

  defstruct paradigm: [%Regex{}]

  def new(nil), do: nil

  def new(r = %Regex{}) do
    struct(__MODULE__, %{paradigm: r})
  end

  def new(_) do
    raise_error("invalid", :invalid)
  end

  def run(%__MODULE__{paradigm: %Regex{} = r}, str) do
    str = Utils.strip_leading_space(str)

    r
    |> Regex.split(str, parts: 2, include_captures: true, trim: true)
    |> case do
      [match, remainder_sentence] ->
        {:ok, {match, remainder_sentence}}

      [match] ->
        r
        |> Regex.split(str)
        |> case do
          ["", ""] -> {:ok, {match, ""}}
          matches -> {:error, {:last_word_failed_match, {r, str, matches}}}
        end

      failure ->
        """
        This is impossible to happen.
        """
        # |> dd(:impossible_scenario)
        |> SyntaxError.raise(:impossible_case)
    end
    # |> dd(:run)
  end

  def run(nil, str), do: {:ok, {str, :inoperative}}

  def raise_error(error_description, error_code) do
    """
    Disambiguator supplied for `ParameterType` is #{error_description}.
    Kindly specify a `%Regex{}`.
    """
    |> SyntaxError.raise(error_code)
  end
end
