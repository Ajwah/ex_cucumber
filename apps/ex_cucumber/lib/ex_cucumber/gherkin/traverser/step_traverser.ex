defmodule ExCucumber.Gherkin.Traverser.Step do
  @moduledoc false

  # alias ExCucumber.Gherkin.Traverser, as: MainTraverser
  alias ExCucumber.Gherkin.Traverser.Ctx

  alias CucumberExpressions.{
    Matcher
    # ParameterType,
    # Parser
  }

  alias ExGherkin.AstNdjson.Step.DataTable
  use ExDebugger.Manual

  def run(%ExGherkin.AstNdjson.Step{} = s, acc, parse_tree) do
    ctx =
      acc
      |> Ctx.update(location: Map.from_struct(s.location), token: s.token, keyword: s.keyword)

    m = Matcher.run(s.text, parse_tree, acc.parameter_type, ctx)
    params = Enum.reverse(m.params)

    {result, def_meta} =
      ctx
      |> Ctx.extra(%{
        fun: m.id,
        cucumber_expression: s.text
      })
      |> acc.module.execute_mfa(%{
        params: params,
        data_table: DataTable.to_map(s.dataTable),
        history: acc.extra.history
      })
      |> dd(:run)

    event = %{
      feature_file: %{
        text: s.text,
        location: ctx.location,
        keyword: ctx.keyword
      },
      cucumber_expression: cucumber_expression(def_meta),
      params: params,
      token: ctx.token,
      result: result
    }

    Ctx.extra(acc, %{
      history: [event | acc.extra.history]
    })
  end

  defp cucumber_expression(def_meta) do
    %{
      formulation: def_meta.cucumber_expression.formulation,
      line: def_meta.line,
      macro: def_meta.macro_usage_gherkin_keyword
    }
  end
end
