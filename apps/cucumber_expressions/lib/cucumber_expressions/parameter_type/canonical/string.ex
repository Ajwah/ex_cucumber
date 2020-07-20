defmodule CucumberExpressions.ParameterType.Canonical.String do
  @moduledoc false
  @regex ~r/^(".*"|'.*')$/

  def meta, do: %{name: :string, type: :string, disambiguator: @regex}
end
