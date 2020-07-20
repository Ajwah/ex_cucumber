defmodule CucumberExpressions.ParameterType.Canonical.Word do
  @moduledoc false
  @regex ~r/[^\s]+/

  def meta, do: %{name: :word, type: :word, disambiguator: @regex}
end
