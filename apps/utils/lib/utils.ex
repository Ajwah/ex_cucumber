defmodule Utils do
  @moduledoc """
  Utils standardized cross app
  """
  alias Utils.{
    Descriptor,
    Random
  }


  defdelegate id, to: Random
  defdelegate id(a), to: Random
  defdelegate length, to: Random
  defdelegate descriptor(tag, key), to: Descriptor, as: :get

  def strip_leading_space(word, _n \\ 1) do
    word
    |> case do
      <<" ", remainder::binary>> -> remainder
      w -> w
    end
  end

  def strip_cwd(file_path, project_root) when is_binary(file_path) do
    file_path
    |> String.replace(project_root, "")
    |> String.trim_leading("/")
  end

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
  defp bulletize_mode(item, _), do: "#{item}"
end
