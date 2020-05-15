defmodule Support.ParameterType.Validator.Integer do
  def run(str, _ \\ :none) do
    str
    |> Integer.parse()
    |> case do
      :error -> {:error, :not_integer, str}
      {int, ""} -> {:ok, int}
      {_, _} -> {:error, :not_integer, str}
    end
  end
end
