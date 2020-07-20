defmodule Support.OptionalsAlternatives.WithAllRelevantCombinations do
  use ExCucumber
  @feature "optionals_alternatives.feature"

  Given._("I/we eat a/several cucumber(s) in one/multiple sitting(s)", do: :ok)
end
