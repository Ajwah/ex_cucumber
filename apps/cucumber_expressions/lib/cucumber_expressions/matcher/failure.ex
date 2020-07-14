defmodule CucumberExpressions.Matcher.Failure do
  @moduledoc false
  import Kernel, except: [raise: 2]
  import CucumberExpressions.Matcher.Data

  # alias __MODULE__.Messages

  defexception message: "",
               ctx: %{},
               error_code: "",
               current_word: "",
               params: [],
               only_spaces_so_far?: false,
               parameter_types: %{},
               remaining_parse_tree: %{}

  @impl true
  def exception({ctx, error_code, m = matcher(), remaining_parse_tree}) do
    struct(__MODULE__, %{
      ctx: ctx,
      error_code: error_code,
      current_word: matcher(m, :current_word),
      params: matcher(m, :params),
      only_spaces_so_far?: matcher(m, :only_spaces_so_far?),
      parameter_types: matcher(m, :parameter_types),
      remaining_parse_tree: remaining_parse_tree
    })
  end

  def raise(ctx, error_code, m = matcher(), remaining_parse_tree) do
    Kernel.reraise(__MODULE__, {ctx, error_code, m, remaining_parse_tree}, [])
  end
end
