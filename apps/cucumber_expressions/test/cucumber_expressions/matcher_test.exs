defmodule CucumberExpressions.MatcherTest do
  @moduledoc false
  use ExUnit.Case

  @fixed_id Utils.id(:fixed)

  alias CucumberExpressions.{
    Matcher,
    ParameterType,
    Parser
  }

  alias CucumberExpressions.Matcher.Failure, as: MatchFailure
  alias Support.MatcherHelper

  require MatcherHelper
  import TestHelper

  describe "edge cases" do
    test "null case" do
      full_sentence = ""
      cucumber_expression = ""

      MatcherHelper.assert_match(full_sentence, cucumber_expression)
    end

    test "singular case" do
      full_sentence = "hello"
      cucumber_expression = "hello"

      MatcherHelper.assert_match(full_sentence, cucumber_expression)
    end

    test "only spaces" do
      full_sentence = "    "
      cucumber_expression = "    "

      MatcherHelper.assert_match(full_sentence, cucumber_expression)
    end

    test "normal sentence with abnormal spacing" do
      full_sentence = "This  is   a     sentence"
      cucumber_expression = "This  is   a     sentence"

      MatcherHelper.assert_match(full_sentence, cucumber_expression)
    end

    test "normal sentence starting with abnormal spacing" do
      full_sentence = "     This is a sentence"
      cucumber_expression = "     This is a sentence"

      MatcherHelper.assert_match(full_sentence, cucumber_expression)
    end

    test "normal sentence ending with abnormal spacing" do
      full_sentence = "This is a sentence    "
      cucumber_expression = "This is a sentence    "

      MatcherHelper.assert_match(full_sentence, cucumber_expression)
    end

    test "normal sentence with abnormal spacing everywhere" do
      full_sentence = "   This  is   a     sentence  "
      cucumber_expression = "   This  is   a     sentence  "

      MatcherHelper.assert_match(full_sentence, cucumber_expression)
    end
  end

  describe "ordinary examples" do
    test "normal sentence with normal spacing" do
      full_sentence = "This is a sentence"
      cucumber_expression = "This is a sentence"

      MatcherHelper.assert_match(full_sentence, cucumber_expression)
    end
  end

  describe "alternatives" do
    test "single alternative group" do
      full_sentence = "This is a sentence"
      cucumber_expression = "This is a sentence/string"
      MatcherHelper.assert_match(full_sentence, cucumber_expression)

      full_sentence = "This is a string"
      MatcherHelper.assert_match(full_sentence, cucumber_expression)
    end

    test "multiple alternatives in 1 group" do
      full_sentences = [
        "This is a 1",
        "This is a 2",
        "This is a 3",
        "This is a 4",
        "This is a 5"
      ]

      cucumber_expression = "This is a 1/2/3/4/5"
      Enum.each(full_sentences, &MatcherHelper.assert_match(&1, cucumber_expression))
    end

    @tag permutations: [
           {1, 11, 21},
           {1, 12, 21},
           {1, 13, 21},
           {1, 11, 22},
           {1, 12, 22},
           {1, 13, 22},
           {1, 11, 23},
           {1, 12, 23},
           {1, 13, 23},
           {2, 11, 21},
           {2, 12, 21},
           {2, 13, 21},
           {2, 11, 22},
           {2, 12, 22},
           {2, 13, 22},
           {2, 11, 23},
           {2, 12, 23},
           {2, 13, 23},
           {3, 11, 21},
           {3, 12, 21},
           {3, 13, 21},
           {3, 11, 22},
           {3, 12, 22},
           {3, 13, 22},
           {3, 11, 23},
           {3, 12, 23},
           {3, 13, 23}
         ],
         cucumber_expression: "This is a 1/2/3 and a 11/12/13 together with a 21/22/23"
    test "multiple alternative groups", ctx do
      to_full_sentence = fn {a, b, c} ->
        "This is a #{a} and a #{b} together with a #{c}"
      end

      full_sentences =
        ctx.permutations
        |> Enum.map(&to_full_sentence.(&1))

      Enum.each(full_sentences, &MatcherHelper.assert_match(&1, ctx.cucumber_expression))
    end

    test "only alternatives" do
      full_sentences = [
        "1",
        "2",
        "3",
        "4",
        "5"
      ]

      cucumber_expression = "1/2/3/4/5"
      Enum.each(full_sentences, &MatcherHelper.assert_match(&1, cucumber_expression))
    end

    test "alternatives with escaped spaces" do
      full_sentences = [
        "1",
        "\\ 2",
        "3\\ ",
        "\\ 4\\ ",
        "\\ \\ 5"
      ]

      cucumber_expression = "1/\\ 2/3\\ /\\ 4\\ /\\ \\ 5"
      Enum.each(full_sentences, &MatcherHelper.assert_match(&1, cucumber_expression))
    end
  end

  describe "optionals" do
    test "usage of optionals" do
      full_sentence = "Order cucumber for tonight"
      cucumber_expression = "Order cucumber(s) for tonight"
      MatcherHelper.assert_match(full_sentence, cucumber_expression)

      full_sentence = "Order cucumbers for tonight"
      MatcherHelper.assert_match(full_sentence, cucumber_expression)
    end

    @tag cucumber_expression: "1 2 3(s) 4(s)",
         full_sentences: [
           "1 2 3 4",
           "1 2 3 4s",
           "1 2 3s 4",
           "1 2 3s 4s"
         ]
    test "usage of multiple optionals", ctx do
      ctx.full_sentences
      |> Enum.each(&MatcherHelper.assert_match(&1, ctx.cucumber_expression))
    end

    @tag cucumber_expression: "1(s) 2(s) 3(s) 4(s)",
         full_sentences: [
           "1 2 3 4",
           "1 2s 3 4",
           "1 2 3 4s",
           "1 2s 3 4s",
           "1 2 3s 4",
           "1 2s 3s 4",
           "1 2 3s 4s",
           "1 2s 3s 4s",
           "1s 2s 3 4",
           "1s 2 3 4",
           "1s 2s 3 4s",
           "1s 2 3 4s",
           "1s 2s 3s 4",
           "1s 2 3s 4",
           "1s 2s 3s 4s",
           "1s 2 3s 4s"
         ]
    test "only optionals", ctx do
      ctx.full_sentences
      |> Enum.each(&MatcherHelper.assert_match(&1, ctx.cucumber_expression))
    end
  end

  describe "parameter usage" do
    def assert_match(full_sentence, cucumber_expression, parse_tree \\ %{}, p, id \\ @fixed_id) do
      Support.MatcherHelper.assert_match2(
        full_sentence,
        cucumber_expression,
        parse_tree,
        p,
        id
      )
    end

    def assert_match_yield(
          full_sentence,
          cucumber_expression,
          parse_tree \\ %{},
          p,
          id \\ @fixed_id,
          fun
        ) do
      Support.MatcherHelper.assert_match_yield2(
        full_sentence,
        cucumber_expression,
        parse_tree,
        p,
        id,
        fun
      )
    end

    test "canonical: {int}" do
      ctx = %{
        param: :int,
        full_sentence: "This is 1 sentence",
        cucumber_expression: "This is {int} sentence"
      }

      param_type =
        ParameterType.new(%{
          name: ctx.param,
          type: :integer,
          validator: {Support.ParameterType.Validator.Integer, :run}
        })

      assert_match_yield(
        ctx.full_sentence,
        ctx.cucumber_expression,
        param_type,
        fn result ->
          assert [eq: "This is ", del: del, ins: ins, eq: " sentence"] =
                   ctx.full_sentence
                   |> String.myers_difference(ctx.cucumber_expression)

          assert "{#{ctx.param}}" == ins
          assert del == "#{result.params[ctx.param]}"
        end
      )
    end

    test "parameters can be inferred from the boundary words without defining a `ParameterType` if no ambiguity involved" do
      ctx = %{
        param: :some_digit,
        full_sentence: "This is 1 sentence",
        cucumber_expression: "This is {some_digit} sentence"
      }

      # This does not define a `some_digit` ParameterType
      param_type = ParameterType.new()

      assert_match_yield(
        ctx.full_sentence,
        ctx.cucumber_expression,
        param_type,
        fn result ->
          assert [eq: "This is ", del: del, ins: ins, eq: " sentence"] =
                   ctx.full_sentence
                   |> String.myers_difference(ctx.cucumber_expression)

          assert "{#{ctx.param}}" == ins
          assert del == "#{result.params[ctx.param]}"
        end
      )
    end

    test "custom: {flight}" do
      ctx = %{
        param: :flight,
        full_sentence: "Take LHR-OSL from Toronto to Istanbul",
        cucumber_expression: "Take {flight} from Toronto to Istanbul"
      }

      param_type =
        ParameterType.new(%{
          name: ctx.param,
          type: :string,
          disambiguator: ~r/^[A-Z]{3}-[A-Z]{3}/
        })

      assert_match_yield(
        ctx.full_sentence,
        ctx.cucumber_expression,
        param_type,
        fn result ->
          assert [eq: "Take ", del: del, ins: ins, eq: " from Toronto to Istanbul"] =
                   ctx.full_sentence
                   |> String.myers_difference(ctx.cucumber_expression)

          assert "{#{ctx.param}}" == ins
          assert del == result.params[ctx.param]
        end
      )
    end

    @tag param: %{key: :date_time, value: "22 June 2017 at 13:40"},
         template_sentence: "I had a meeting on % in New York"
    test "not so trivial: {date_time}", ctx do
      ctx = %{
        param: ctx.param,
        template_sentence: ctx.template_sentence,
        full_sentence: String.replace(ctx.template_sentence, "%", ctx.param.value),
        cucumber_expression: String.replace(ctx.template_sentence, "%", "{#{ctx.param.key}}")
      }

      param_type =
        ParameterType.new(%{
          name: ctx.param.key,
          type: Support.ParameterType.Validator.DateTime,
          validator: {Support.ParameterType.Validator.DateTime, :run}
        })

      assert_match_yield(
        ctx.full_sentence,
        ctx.cucumber_expression,
        param_type,
        fn result ->
          assert [{:eq, "I had a meeting on "}, _, _, _, _, eq: "in New York"] =
                   ctx.template_sentence
                   |> String.myers_difference(ctx.full_sentence)

          assert [eq: "I had a meeting on ", del: del, ins: ins, eq: " in New York"] =
                   ctx.template_sentence
                   |> String.myers_difference(ctx.cucumber_expression)

          assert "{#{ctx.param.key}}" == ins

          assert %Support.ParameterType.Validator.DateTime{value: ctx.param.value} ==
                   result.params[ctx.param.key]
        end
      )
    end

    @tag params: [
           flight: "LHR-OSL",
           origin: "Toronto",
           destination: "Istanbul",
           departure_date: "Monday, 22 June 2017",
           departure_time: "13:40",
           arrival_date: "Tuesday, 23 June 2017",
           arrival_time: "21:15",
           total_flight_time: "17 hours",
           price: "3500 CAD"
         ],
         template_sentence:
           "Take %1 from %2 to %3 on %4 at %5 to arrive by %6 at %7 for a total flight time of %8 at a discounted price of %9 in total",
         full_sentence:
           "Take LHR-OSL from toROnto to ISTANBUL on Monday, 22 June 2017 at 13:40 to arrive by Tuesday, 23 June 2017 at 21:15 for a total flight time of 17 hours at a discounted price of 3500 CAD in total",
         cucumber_expression:
           "Take {flight} from {origin} to {destination} on {departure_date} at {departure_time} to arrive by {arrival_date} at {arrival_time} for a total flight time of {total_flight_time} at a discounted price of {price} in total"

    test "various params, including a pre-transformer for city:", ctx do
      param_type =
        %{name: :flight, type: :string, validator: ~r/^(?<flight>[A-Z]{3}-[A-Z]{3})$/}
        |> ParameterType.new()
        |> ParameterType.add(%{
          name: :origin,
          type: Support.ParameterType.Transformer.City,
          validator: Support.ParameterType.Validator.City,
          transformer: Support.ParameterType.Transformer.City
        })
        |> ParameterType.add(%{
          name: :destination,
          type: Support.ParameterType.Transformer.City,
          validator: Support.ParameterType.Validator.City,
          transformer: Support.ParameterType.Transformer.City
        })
        |> ParameterType.add(%{
          name: :departure_date,
          type: Support.ParameterType.Validator.Date,
          validator: Support.ParameterType.Validator.Date
        })
        |> ParameterType.add(%{
          name: :arrival_date,
          type: Support.ParameterType.Validator.Date,
          validator: Support.ParameterType.Validator.Date
        })
        |> ParameterType.add(%{
          name: :departure_time,
          type: Support.ParameterType.Validator.Time,
          validator: Support.ParameterType.Validator.Time
        })
        |> ParameterType.add(%{
          name: :arrival_time,
          type: Support.ParameterType.Validator.Time,
          validator: Support.ParameterType.Validator.Time
        })
        |> ParameterType.add(%{
          name: :total_flight_time,
          type: Support.ParameterType.Validator.TotalTime,
          validator: Support.ParameterType.Validator.TotalTime
        })
        |> ParameterType.add(%{
          name: :price,
          type: Support.ParameterType.Validator.Price,
          validator: Support.ParameterType.Validator.Price
        })

      assert_match_yield(
        ctx.full_sentence,
        ctx.cucumber_expression,
        param_type,
        fn result ->
          params =
            ctx.template_sentence
            |> String.myers_difference(ctx.cucumber_expression)
            |> Enum.reduce([], fn
              {:ins, <<"{", ins::binary>>}, a ->
                key =
                  ins
                  |> String.trim_trailing("}")
                  |> String.to_atom()

                value =
                  result.params
                  |> Keyword.get(key, %{value: :not_found})
                  |> case do
                    str when is_binary(str) -> str
                    other -> other |> Map.get(:value, :not_found)
                  end

                [{key, value} | a]

              _, a ->
                a
            end)
            |> Enum.reverse()

          assert ctx.params == params
        end
      )
    end

    test "disambiguator resolves the ambiguous: {region}" do
      ctx = %{
        param: :region,
        full_sentence:
          "I would like to visit the Federation of Rhodesia and Nyasaland and Morocco also",
        # The point of contention is that the region: 'Federation of Rhodesia and Nyasaland' is one
        # word but it has the word 'and' inside of it that can be confused for the boundary word 'and' at:
        # {region} and {region}
        cucumber_expression: "I would like to visit the {region} and {region} also",
        template_sentence: "I would like to visit the % and % also"
      }

      assert_match_yield(
        ctx.full_sentence,
        ctx.cucumber_expression,
        # ParameterType without disambiguator will mistaken the regions
        ParameterType.new(),
        fn result ->
          assert [
                   eq: "I would like to visit the ",
                   del: _,
                   ins: region,
                   eq: " and ",
                   del: _,
                   ins: region,
                   eq: " also"
                 ] =
                   ctx.template_sentence
                   |> String.myers_difference(ctx.cucumber_expression)

          assert "{#{ctx.param}}" == region
          # It will mistaken the regions to respectively be:
          assert [region: "Nyasaland and Morocco", region: "Federation of Rhodesia"] ==
                   result.params
        end
      )

      param_type =
        ParameterType.new(%{
          name: ctx.param,
          type: :string,
          disambiguator: ~r/^(Federation of Rhodesia and Nyasaland|Morocco)/
        })

      assert_match_yield(
        ctx.full_sentence,
        ctx.cucumber_expression,
        param_type,
        fn result ->
          assert [
                   eq: "I would like to visit the ",
                   del: _,
                   ins: region,
                   eq: " and ",
                   del: _,
                   ins: region,
                   eq: " also"
                 ] =
                   ctx.template_sentence
                   |> String.myers_difference(ctx.cucumber_expression)

          assert "{#{ctx.param}}" == region

          assert [region: "Morocco", region: "Federation of Rhodesia and Nyasaland"] ==
                   result.params
        end
      )
    end

    @tag params: [
           a: "1 and 2",
           b: "2",
           c: "3 + 1 - 1 = 3",
           d: "4"
         ],
         full_sentence: "1 and 2 2 3 + 1 - 1 = 3 4",
         cucumber_expression: "{a} {b} {c} {d}",
         template_sentence: "% % % %"
    test "only params:", ctx do
      param_type =
        %{name: :a, type: :integer, disambiguator: ~r/^\d+ and \d+/}
        |> ParameterType.new()
        |> ParameterType.add(%{name: :b, type: :integer, disambiguator: ~r/^\d+/})
        |> ParameterType.add(%{name: :c, type: :integer, disambiguator: ~r/^\d+.+= \d+/})
        |> ParameterType.add(%{name: :d, type: :integer, disambiguator: ~r/^\d+/})

      assert_match_yield(
        ctx.full_sentence,
        ctx.cucumber_expression,
        param_type,
        fn result ->
          params =
            ctx.template_sentence
            |> String.myers_difference(ctx.cucumber_expression)
            |> Enum.reduce([], fn
              {:ins, <<"{", ins::binary>>}, a ->
                key =
                  ins
                  |> String.trim_trailing("}")
                  |> String.to_atom()

                value =
                  result.params
                  |> Keyword.get(key, :not_found)

                [{key, value} | a]

              _, a ->
                a
            end)
            |> Enum.reverse()

          assert ctx.params == params
        end
      )
    end
  end

  describe "mixture of optionals, alternatives and parameters" do
    # test "usage of all" do
    #   param = :int
    #   full_sentence = "Order 1 cucumber for tonight"
    #   cucumber_expression = "Order {int} cucumber(s) for tonight"
    #   MatcherHelper.assert_match(full_sentence, cucumber_expression)

    #   full_sentence = "Order 2 cucumbers for tonight"
    #   MatcherHelper.assert_match(full_sentence, cucumber_expression)
    # end
  end

  describe "Matching with a ParseTree encompassing multiple cucumber expressions" do
    test "regular" do
      cucumber_expression1 = "The sum of {addend} and {addend} is {sum}"
      cucumber_expression2 = "The difference of {subtrahend} from {minuend} is {difference}"
      cucumber_expression3 = "The product of {multiplier} and {multiplicand} is {product}"

      cucumber_expression4 =
        "The division of {dividend} by {divisor} is {quotient} with remainder {remainder}"

      parse_tree = %{}
      parse_tree = Parser.run(cucumber_expression1, parse_tree)
      parse_tree = Parser.run(cucumber_expression2, parse_tree)
      parse_tree = Parser.run(cucumber_expression3, parse_tree)
      parsed_result = CucumberExpressions.parse(cucumber_expression4, parse_tree)

      param_type = ParameterType.new()

      Matcher.run("The sum of 1 and 2 is 3", parsed_result, param_type) |> IO.inspect()
    end

    test "with repitition" do
      full_sentence0 = "I {love} this sentence"
      full_sentence1 = "I {hate} this sentence"
      full_sentence2 = "This is {int} sentence"
      full_sentence3 = "This is {int} {color} sentence"
      full_sentence4 = "This sentence is {bord}"
      full_sentence5 = "This {int} sentence is {color}"

      parse_tree = %{}
      parse_tree = Parser.run(full_sentence1, parse_tree)
      parse_tree = Parser.run(full_sentence1, parse_tree)
      parse_tree = Parser.run(full_sentence2, parse_tree)
      parse_tree = Parser.run(full_sentence3, parse_tree)
      parse_tree = Parser.run(full_sentence5, parse_tree)
      parse_tree = Parser.run(full_sentence0, parse_tree)
      parse_tree = Parser.run(full_sentence1, parse_tree)
      parse_tree = Parser.run(full_sentence1, parse_tree)
      parse_tree = Parser.run(full_sentence3, parse_tree)
      parse_tree = Parser.run(full_sentence2, parse_tree)
      parse_tree = Parser.run(full_sentence4, parse_tree)
      parse_tree = Parser.run(full_sentence2, parse_tree)
      parse_tree = Parser.run(full_sentence2, parse_tree)
      parse_tree = Parser.run(full_sentence4, parse_tree)
      parse_tree = Parser.run(full_sentence5, parse_tree)
      parse_tree = Parser.run(full_sentence0, parse_tree)
      parsed_result = CucumberExpressions.parse(full_sentence5, parse_tree)

      param_type =
        %{name: :int, type: :integer, disambiguator: ~r/^\d+/}
        |> ParameterType.new()
        |> ParameterType.add(%{name: :string, type: :string, disambiguator: ~r/^[a-zA-Z]+/})
        # |> ParameterType.add(%{name: :love, type: :string, disambiguator: ~r/^(love|adore)/})
        # |> ParameterType.add(%{name: :hate, type: :string, disambiguator: ~r/^(hate|despise|detest)/})
        |> ParameterType.add(%{name: :bord, type: :string, disambiguator: ~r/^[a-zA-Z]+/})
        |> ParameterType.add(%{name: :color, type: :string, disambiguator: ~r/^[a-zA-Z]+/})

      assert_specific_raise(MatchFailure, :multiple_params_collision_ambiguity, fn ->
        Matcher.run("I detest this sentence", parsed_result, param_type)
      end)
    end
  end
end
