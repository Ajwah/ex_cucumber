defmodule ExCucumber.Exceptions.Messages.UnableToAutoMatchParam do
  @moduledoc false
  alias ExCucumber.{
    Exceptions.MatchFailure,
    Utils
  }

  # alias ExCucumber.Exceptions.Messages.Common, as: CommonMessages
  alias CucumberExpressions.Parser.ParseTree

  def render(%MatchFailure{error_code: :unable_to_auto_match_param} = f, :brief) do
    module_name = f.ctx.__struct__.module_name(f.ctx)

    """
    Unable To Auto Match Param: #{Utils.smart_quotes(f.ctx.sentence)} in `#{module_name}`
    """
  end

  def render(%MatchFailure{error_code: :unable_to_auto_match_param} = f, :verbose) do
    module_name = f.ctx.__struct__.module_name(f.ctx)

    """
    # Unable To Auto Match Param
    ## Summary
    When a `Cucumber Expression` embeds `Parameter Type`(s) for which there is no `disambiguator` defined, then the `Matcher`
    will attempt an auto `Match`. This works in trivial cases, but other cases require a `disambiguator` to help resolve
    the ambiguity.

    Known cases of conflict are:
      * Succeeding params without specifying a disambiguator for the preceding one, e.g.: #{Utils.smart_quotes("I {action} {food_drink} every day")}

    In the above example, if no `disambiguator` has been defined for the `Custom Parameter Type` corresponding to the param `action`
    then auto matching will fail.

    ## Quick Fix
    Introduce a Parameter Type to resolve the ambiguity by consulting `@behaviour ExCucumber.CustomParameterType`
    and implementing the `callback` `disambiguate` accordingly. Here is a general example:
    https://github.com/Ajwah/ex_cucumber/blob/5633c889bf177dc1e528c4d76eac4c8979b2f01e/apps/ex_cucumber/test/helpers/parameter_types/city.ex#L2

    Then you can incorporate this `Parameter Type` into your `feature` file as follows:
    https://github.com/Ajwah/ex_cucumber/blob/5633c889bf177dc1e528c4d76eac4c8979b2f01e/apps/ex_cucumber/test/support/modules/params/custom.ex#L1-L25

    ## Details
    * Error: Unable To Match
    * Feature File: `#{Exception.format_file_line(f.ctx.feature_file, f.ctx.location.line, f.ctx.location.column)}`
    * Module: `#{module_name}`
    * Cause: Missing `disambiguator` to match: #{Utils.smart_quotes(f.ctx.sentence)}

    #{details(f)}
    """
  end

  def details(f) do
    violating_cucumber_expressions =
      ParseTree.endings(f.extra.remaining_parse_tree)
      |> Enum.reduce([], fn e, a ->
        e
        |> String.split(" ", trim: true)
        |> Enum.reduce({[], []}, fn
          word = <<"{", _::binary>>, {results, []} ->
            {results, [word]}

          word = <<"{", _::binary>>, {results, prev_words} ->
            {results, [word | prev_words]}

          _, {results, []} ->
            {results, []}

          _, {results, [param]} ->
            {results, [param]}

          _, {results, successions} ->
            {[successions |> Enum.reverse() |> Enum.join(" ") | results], []}
        end)
        |> case do
          {results, []} -> results
          {results, [_]} -> results
          {results, successions} -> [Enum.reverse(successions) | results]
        end
        |> Enum.reject(& &1)
        |> case do
          [] ->
            a

          results ->
            [
              String.replace(e, results, fn e ->
                IO.ANSI.red_background() <> e <> IO.ANSI.reset()
              end)
              | a
            ]
        end
      end)

    if violating_cucumber_expressions == [] do
      ""
    else
      """
      To assist you in narrowing down the issue, following are the possible `cucumber expressions` that may apply:
      #{Utils.bullitize(violating_cucumber_expressions, :as_smart_quoted_strings)}
      """
    end
  end
end
