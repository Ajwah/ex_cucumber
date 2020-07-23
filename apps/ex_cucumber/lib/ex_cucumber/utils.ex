defmodule ExCucumber.Utils do
  @moduledoc false
  def smart_quotes(s), do: "“#{s}”"

  def bullitize(ls, mode \\ :as_atoms, padding \\ "  ") do
    ls
    |> Enum.map(&"#{padding}* #{bulletize_mode(&1, mode)}")
    |> Enum.join("\n")
  end

  def atomize(s, option \\ :use_backticks)
  def atomize(s, :no_backticks), do: ":#{s}"
  def atomize(s, :use_backticks), do: s |> atomize(:no_backticks) |> backtick
  def backtick(s) when is_binary(s), do: "`#{s}`"
  defp bulletize_mode(item, :as_atoms), do: item |> atomize
  defp bulletize_mode(item, :as_smart_quoted_strings), do: smart_quotes(item)
  defp bulletize_mode(item, _), do: "#{item}"
end
