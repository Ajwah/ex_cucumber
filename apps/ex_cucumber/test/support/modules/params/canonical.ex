defmodule Support.Params.Canonical do
  use ExCucumber
  @feature "canonical_params.feature"

  Given._("I daily eat {int} cucumbers", args, do: assert(Keyword.fetch!(args.params, :int) == 3))
  When._("I have {float} cucumbers", args, do: assert(Keyword.fetch!(args.params, :float) == 7.5))
  And._("{word} is a new day", args, do: assert(Keyword.fetch!(args.params, :word) == "today"))

  Then._("I will eat accordingly my ration of {int} cucumbers", args,
    do: Keyword.fetch!(args.params, :int) == 3
  )
end
