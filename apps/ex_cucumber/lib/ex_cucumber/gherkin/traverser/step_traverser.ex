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
  # use ExDebugger.Manual

  def run(%ExGherkin.AstNdjson.Step{} = s, acc, parse_tree) do
    [hd | _] = acc.extra.context_history

    if acc.runtime_filters && acc.runtime_filters.line && hd.name != :background do
      acc.extra.context_history
      |> Enum.find(false, fn %{location: %{line: line}} -> line == acc.runtime_filters.line end)
      |> case do
        false -> acc
        _ -> do_step(s, acc, parse_tree)
      end
    else
      do_step(s, acc, parse_tree)
    end
  end

  defp do_step(%ExGherkin.AstNdjson.Step{} = s, acc, parse_tree) do
    ctx =
      Ctx.update(acc, location: Map.from_struct(s.location), token: s.token, keyword: s.keyword)

    m = Matcher.run(s.text, parse_tree, acc.parameter_type, ctx)

    unless m[:id] do
      raise """
      Anomaly. `:id` should always be present.
      #{inspect(m, label: :m, pretty: true, limit: :infinity)}
      #{inspect(parse_tree, label: :parse_tree, pretty: true, limit: :infinity)}
      #{inspect(acc.parameter_type, label: :parameter_type, pretty: true, limit: :infinity)}
      #{inspect(ctx, label: :ctx, pretty: true, limit: :infinity)}
      """
    end

    params =
      m.params
      |> Enum.reverse()

    # IO.inspect(acc, limit: :infinity, pretty: true, label: :acc)
    {result, def_meta} =
      ctx
      |> Ctx.extra(%{
        fun: m.id,
        cucumber_expression: s.text
      })
      |> acc.module.execute_mfa(%{
        state: acc.extra.state,
        params: params,
        doc_string: s.docString,
        data_table: DataTable.to_map(s.dataTable, examples(acc.extra)),
        raw_data_table: DataTable.to_lists(s.dataTable, examples(acc.extra)),
        step_history: acc.extra.step_history,
        context_history: acc.extra.context_history,
        feature_file: %{
          text: s.text,
          location: ctx.location,
          keyword: ctx.keyword
        }
      })

    # |> dd(:run)

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

    state =
      result
      |> case do
        {:ok, new_state} -> new_state
        _ -> acc.extra.state
      end

    Ctx.extra(acc, %{
      step_history: [event | acc.extra.step_history],
      state: state
    })
  end

  defp cucumber_expression(def_meta) do
    %{
      formulation: def_meta.cucumber_expression.formulation,
      line: def_meta.line,
      macro: def_meta.macro_usage_gherkin_keyword
    }
  end

  defp examples(extra) do
    if Map.has_key?(extra, :examples) do
      extra.examples.row
    else
      %{}
    end
  end
end
