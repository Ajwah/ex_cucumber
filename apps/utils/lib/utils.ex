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
end
