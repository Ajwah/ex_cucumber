defmodule StringReducer do
  def reduce(str, initial_val, fun), do: traverse(str, initial_val, fun)

  defp traverse("", acc, _), do: acc

  defp traverse(<<char::utf8, rest::binary>>, acc, fun),
    do: traverse(rest, fun.(<<char::utf8>>, acc), fun)
end
