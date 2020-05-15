defmodule Utils.Descriptor do
  @moduledoc false

  def get([tag], key) do
    tag
    |> Keyword.fetch!(key)
  end
end
