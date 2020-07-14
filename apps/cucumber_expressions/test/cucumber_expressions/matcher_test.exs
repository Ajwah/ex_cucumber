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
        # |> IO.inspect(label: :full_sentences)

      Enum.each(full_sentences, &MatcherHelper.T.assert_match(&1, [ctx.cucumber_expression], :multiple_alternative_groups))
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

    test "alternatives at start" do
      full_sentences = [
        "X A1 A2 A3 A4",
        "Y A1 A2 A3 A4",
        "Z A1 A2 A3 A4",
      ]

      cucumber_expression = "X/Y/Z A1 A2 A3 A4"
      Enum.each(full_sentences, &MatcherHelper.assert_match(&1, cucumber_expression))
    end

    test "alternatives in middle" do
      full_sentences = [
        "A1 A2 X A3 A4",
        "A1 A2 Y A3 A4",
        "A1 A2 Z A3 A4",
      ]

      cucumber_expression = "A1 A2 X/Y/Z A3 A4"
      Enum.each(full_sentences, &MatcherHelper.assert_match(&1, cucumber_expression))
    end

    test "alternatives at end" do
      full_sentences = [
        "A1 A2 A3 A4 X",
        "A1 A2 A3 A4 Y",
        "A1 A2 A3 A4 Z",
      ]

      cucumber_expression = "A1 A2 A3 A4 X/Y/Z"
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
    setup ctx do
      if ctx[:bulk_test_data] do
        {
          :ok,
          %{
            bulk_cucumber_expressions: ctx.bulk_test_data
              |> Enum.map(fn {scenario, test_data} ->
                %{
                  scenario: scenario,
                  cucumber_expressions: Support.CucumberExpression.prepare_all(test_data),
                }
              end)
          }
        }
      else
        {:ok, %{cucumber_expressions: Support.CucumberExpression.prepare_all(ctx.test_data)}}
      end
    end

    @tag bulk_test_data: [
      all_different: [
        {:a, "A1 A2 A3 A4 A5", []},
        {:b, "B1 B2 B3 B4 B5", []},
        {:c, "C1 C2 C3 C4 C5", []},
        {:d, "D1 D2 D3 D4 D5", []},
      ], intersecting_beginning: [
        {:a, "A1 A2 T3 A4 A5", []},
        {:b, "B1 B2 T3 B4 B5", []},
        {:c, "C1 C2 T3 C4 C5", []},
        {:d, "D1 D2 T3 D4 D5", []},
      ], intersecting_middle: [
        {:a, "A1 A2 T3 A4 A5", []},
        {:b, "B1 B2 T3 B4 B5", []},
        {:c, "C1 C2 T3 C4 C5", []},
        {:d, "D1 D2 T3 D4 D5", []},
      ], intersecting_ending: [
        {:a, "A1 A2 T3 A4 A5", []},
        {:b, "B1 B2 T3 B4 B5", []},
        {:c, "C1 C2 T3 C4 C5", []},
        {:d, "D1 D2 T3 D4 D5", []},
      ], intersecting_various: [
        {:a, "A1 A2 T3 A4 A5", []},
        {:b, "B1 A2 T3 B4 B5", []},
        {:c, "C1 C2 T3 C4 C5", []},
        {:d, "D1 D2 T3 C4 D5", []},
      ]
    ]
    test "Plain Cases", ctx do
      Enum.each(ctx.bulk_cucumber_expressions, &runner/1)
    end

    @tag test_data: [
      {:summation, "The sum of {addend} and {addend} is {sum}", [addend: 1, addend: 2, sum: 3]},
      {:differentiation, "The difference of {subtrahend} from {minuend} is {difference}", [subtrahend: 3, minuend: 6, difference: 3]},
      {:multiplication, "The product of {multiplier} and {multiplicand} is {product}", [multiplier: 3, multiplicand: 4, product: 12]},
      {:division, "The division of {dividend} by {divisor} is {quotient} with remainder {remainder}", [dividend: 12, divisor: 4, quotient: 3, remainder: 0]},
    ]
    test "Intersection first word only", ctx do
      runner(ctx, fn input, result ->
        assert Enum.reverse(result.params) in input.parameters.both
      end)
    end

    @tag bulk_test_data: [
      intersecting_beginning: [
        {:a, "{Z} A1 A2 A3 A4", [Z: 1]},
        {:b, "{Z} B1 B2 B3 B4", [Z: 2]},
        {:c, "{Z} C1 C2 C3 C4", [Z: "ABCD"]},
        {:d, "{Z} D1 D2 D3 D4", [Z: "."]},
      ],
      intersecting_middle: [
        {:a, "A1 A2 {Z} A4 A5", [Z: 1]},
        {:b, "B1 B2 {Z} B4 B5", [Z: 2]},
        {:c, "C1 C2 {Z} C4 C5", [Z: "ABCD"]},
        {:d, "D1 D2 {Z} D4 D5", [Z: "."]},
      ],
      intersecting_ending: [
        {:a, "A1 A2 A3 A4 {Z}", [Z: 1]},
        {:b, "B1 B2 B3 B4 {Z}", [Z: 2]},
        {:c, "C1 C2 C3 C4 {Z}", [Z: "ABCD"]},
        {:d, "D1 D2 D3 D4 {Z}", [Z: "."]},
      ],
      intersecting_various: [
        {:a, "{Z} A1 A2 A3 A4 A5", [Z: 1]},
        {:b, "{Z} B1 B2 {T} B4 B5", [Z: 2, T: 0]},
        {:c, "C1 {Z} C2 {T} C4 C5", [Z: "ABCD", T: 1]},
        {:d, "D1 {Z} D3 {T} D5", [Z: ".", T: 2]},
      ],
    ]
    test "Custom Parameter Type Cases", ctx do
      Enum.each(ctx.bulk_cucumber_expressions, &runner(&1, fn input, result ->
        assert Enum.reverse(result.params) in input.parameters.both
      end))
    end

    @tag bulk_test_data: [
      intersecting_beginning: [
        {:a, "X/Y/Z A1 A2 A3 A4", []},
        {:b, "X/Y/Z B1 B2 B3 B4", []},
        {:c, "X/Y/Z C1 C2 C3 C4", []},
        {:d, "X/Y/Z D1 D2 D3 D4", []},
      ],
      intersecting_middle: [
        {:a, "A1 A2 X/Y/Z A4 A5", []},
        {:b, "B1 B2 X/Y/Z B4 B5", []},
        {:c, "C1 C2 X/Y/Z C4 C5", []},
        {:d, "D1 D2 X/Y/Z D4 D5", []},
      ],
      intersecting_ending: [
        {:a, "A1 A2 A3 A4 X/Y/Z", []},
        {:b, "B1 B2 B3 B4 X/Y/Z", []},
        {:c, "C1 C2 C3 C4 X/Y/Z", []},
        {:d, "D1 D2 D3 D4 X/Y/Z", []},
      ],
      intersecting_various: [
        {:a, "X/Y/Z A1 A2 A3 A4 A5", []},
        {:b, "X/Y/Z B1 B2 Q/R/S B4 B5", []},
        {:c, "C1 X/Y/Z C2 Q/R/S C4 C5", []},
        {:d, "D1 X/Y/Z D3 Q/R/S D5", []},
      ],
    ]
    test "Alternatives Cases", ctx do
      Enum.each(ctx.bulk_cucumber_expressions, &runner(&1, fn input, result ->
        assert Enum.reverse(result.params) in input.parameters.both
      end))
    end

    @tag bulk_test_data: [
      intersecting_beginning: [
        {:a, "X(s) A1 A2 A3 A4", []},
        {:b, "X(s) B1 B2 B3 B4", []},
        {:c, "X(s) C1 C2 C3 C4", []},
        {:d, "X(s) D1 D2 D3 D4", []},
      ],
      intersecting_middle: [
        {:a, "A1 A2 X(s) A4 A5", []},
        {:b, "B1 B2 X(s) B4 B5", []},
        {:c, "C1 C2 X(s) C4 C5", []},
        {:d, "D1 D2 X(s) D4 D5", []},
      ],
      intersecting_ending: [
        {:a, "A1 A2 A3 A4 X(s)", []},
        {:b, "B1 B2 B3 B4 X(s)", []},
        {:c, "C1 C2 C3 C4 X(s)", []},
        {:d, "D1 D2 D3 D4 X(s)", []},
      ],
      intersecting_various: [
        {:a, "X(s) A1 A2 A3 A4 A5", []},
        {:b, "X(s) B1 B2 Q(s) B4 B5", []},
        {:c, "C1 X(s) C2 Q(s) C4 C5", []},
        {:d, "D1 X(s) D3 Q(s) D5", []},
      ],
    ]
    test "Optionals Cases", ctx do
      Enum.each(ctx.bulk_cucumber_expressions, &runner(&1, fn input, result ->
        assert Enum.reverse(result.params) in input.parameters.both
      end))
    end

    def runner(ctx, fun) do
      ctx.cucumber_expressions
      |> Map.delete(:all)
      |> Enum.each(fn {_, e = %Support.CucumberExpression{}} ->
        e.instances
        |> Enum.each(fn input = %{parameters: _, instance: instance} ->
          instance
          |> MatcherHelper.T.assert_match_yield(ctx.cucumber_expressions.all, ctx[:scenario], fn result ->
            fun.(input, result)
          end)
        end)
      end)
    end

    def runner(ctx) do
      ctx.cucumber_expressions
      |> Map.delete(:all)
      |> Enum.each(fn {_, e = %Support.CucumberExpression{}} ->
        e.instances
        |> Enum.each(fn %{parameters: _, instance: instance} ->
          instance
          |> MatcherHelper.T.assert_match(ctx.cucumber_expressions.all, ctx[:scenario])
        end)
      end)
    end

    @tag test_data: []
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
