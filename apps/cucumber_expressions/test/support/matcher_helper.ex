defmodule Support.MatcherHelper do
  @moduledoc false

  alias CucumberExpressions.{
    Matcher,
    ParameterType
  }

  @fixed_id Utils.id(:fixed)
  defmacro assert_match(
             full_sentence,
             cucumber_expression,
             parse_tree \\ %{},
             p \\ ParameterType.new(),
             id \\ @fixed_id
           ) do
    quote location: :keep do
      parsed_result =
        CucumberExpressions.parse(
          unquote(cucumber_expression),
          unquote(Macro.escape(parse_tree)),
          unquote(id)
        )

      result = Matcher.run(unquote(full_sentence), parsed_result, unquote(Macro.escape(p)))
      assert result.end == unquote(cucumber_expression)
      assert result.id == unquote(id)
      result
    end
  end

  defmacro assert_match_yield(
             full_sentence,
             cucumber_expression,
             parse_tree,
             p \\ ParameterType.new(),
             id \\ @fixed_id,
             fun
           ) do
    quote location: :keep do
      result =
        Support.MatcherHelper.assert_match(
          unquote(full_sentence),
          unquote(cucumber_expression),
          unquote(parse_tree),
          unquote(p),
          unquote(id)
        )

      unquote(fun).(result)
    end
  end

  defmacro assert_match2(full_sentence, cucumber_expression, parse_tree, p, id) do
    quote location: :keep do
      parsed_result =
        CucumberExpressions.parse(
          unquote(cucumber_expression),
          unquote(parse_tree),
          unquote(id)
        )

      result = Matcher.run(unquote(full_sentence), parsed_result, unquote(p))
      assert result.end == unquote(cucumber_expression)
      assert result.id == unquote(id)
      result
    end
  end

  defmacro assert_match_yield2(
             full_sentence,
             cucumber_expression,
             parse_tree,
             p,
             id,
             fun
           ) do
    quote location: :keep do
      result =
        Support.MatcherHelper.assert_match2(
          unquote(full_sentence),
          unquote(cucumber_expression),
          unquote(parse_tree),
          unquote(p),
          unquote(id)
        )

      unquote(fun).(result)
    end
  end

  def fixture, do: %{fixed_id: @fixed_id}
end
