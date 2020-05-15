defmodule CucumberExpressions.Matcher.Failure do
  @moduledoc false
  import Kernel, except: [raise: 2]
  import CucumberExpressions.Matcher.Data

  defexception message: "",
               error_code: "",
               current_word: "",
               params: [],
               only_spaces_so_far?: false,
               parameter_types: %{},
               remaining_parse_tree: %{}

  @impl true
  def exception({msg, error_code, m = matcher(), remaining_parse_tree}) do
    struct(__MODULE__, %{
      message: msg,
      error_code: error_code,
      current_word: matcher(m, :current_word),
      params: matcher(m, :params),
      only_spaces_so_far?: matcher(m, :only_spaces_so_far?),
      parameter_types: matcher(m, :parameter_types),
      remaining_parse_tree: remaining_parse_tree
    })
  end

  def raise(msg, error_code, m = matcher(), remaining_parse_tree) do
    Kernel.raise(__MODULE__, {msg, error_code, m, remaining_parse_tree})
  end
end
