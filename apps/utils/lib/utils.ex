defmodule Utils do
  @moduledoc """
  Utils standardized cross app
  """

  alias Utils.Random

  defdelegate id, to: Random
  defdelegate id(a), to: Random
  defdelegate length, to: Random
end
