defmodule CucumberExpressions.Utils.Random do
  @moduledoc """
  Generate random id with a risk of repeat as being about the same as
  that of you being hit by a meteorite.
  """
  use Puid, total: 10.0e6, risk: 1.0e12

  @type t() :: String.t()

  @spec id :: t()
  def id, do: generate()

  @spec id(:fixed) :: t()
  def id(:fixed), do: "000000000000000"

  def length, do: 15
end
