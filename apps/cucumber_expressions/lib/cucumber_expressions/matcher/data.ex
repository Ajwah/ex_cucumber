defmodule CucumberExpressions.Matcher.Data do
  @moduledoc false
  import Record

  defrecord :matcher,
    current_word: "",
    params: [],
    parameter_types: %{},
    only_spaces_so_far?: false

  @type t() ::
          record(:matcher,
            current_word: String.t(),
            params: list,
            parameter_types: map,
            only_spaces_so_far?: boolean
          )
end
