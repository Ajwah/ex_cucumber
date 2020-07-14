defmodule Support.MatcherHelper do
  @moduledoc false

  alias CucumberExpressions.{
    Matcher,
    ParameterType,
    Parser
  }

  defmodule T do
    @fixed_id Utils.id(:fixed)
    import ExUnit.Assertions
    use ExDebugger.Manual

    def assert_match(full_sentence, [hd | tl] = cucumber_expressions, scenario, p \\ ParameterType.new(), id \\ @fixed_id) do
      t1 = :os.system_time(:millisecond)
      parse_tree = Enum.reduce(tl, %{}, &Parser.run/2)
      |> dd(:parse_tree)

      t2 = :os.system_time(:millisecond)
      parsed_result = CucumberExpressions.parse(hd, parse_tree, id)
      |> dd(:parsed_result)

      t3 = :os.system_time(:millisecond)
      result = Matcher.run(full_sentence, parsed_result, p)
      |> dd(:result)

      t4 = :os.system_time(:millisecond)
      [parse_tree: t2 - t1, cucumber_expression_parse: t3 - t2, matcher: t4 - t3] |> dd(:timing)

      if scenario do
        assert result.end in cucumber_expressions, "Expected truthy, got false. Scenario: #{scenario}"
        assert result.id == id, "Expected truthy, got false. Scenario: #{scenario}"
      else
        assert result.end in cucumber_expressions
        assert result.id == id
      end
      result
    end

    def assert_match_yield(full_sentence, cucumber_expressions, scenario, p \\ ParameterType.new(), id \\ @fixed_id, fun) when is_function(fun) do
      result = assert_match(full_sentence, cucumber_expressions, scenario, p, id)
      fun.(result)
    end
  end

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
