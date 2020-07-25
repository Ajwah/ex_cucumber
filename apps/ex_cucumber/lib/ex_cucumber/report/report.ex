defmodule ExCucumber.Report do
  @moduledoc false

  defstruct total: 0,
            passed: 0,
            failed: [],
            skipped: 0

  def new, do: %__MODULE__{}

  def record(%__MODULE__{} = m, :passed), do: %{m | passed: m.passed + 1} |> total()

  def record(%__MODULE__{} = m, details),
    do: %{m | failed: [details | Map.fetch!(m, :failed)]} |> total()

  def total(%__MODULE__{} = m), do: %{m | total: m.total + 1}
end
