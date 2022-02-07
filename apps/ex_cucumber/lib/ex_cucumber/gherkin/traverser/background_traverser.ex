defmodule ExCucumber.Gherkin.Traverser.Background do
  @moduledoc false

  alias ExCucumber.Gherkin.Traverser.Ctx
  alias ExCucumber.Gherkin.Traverser, as: MainTraverser

  alias ExGherkin.AstNdjson.{
    Background,
    Step
  }

  def run(%Background{} = b, acc, parse_tree) do
    acc = Ctx.extra(acc, background_meta(b, acc))

    steps =
      if b.steps do
        b.steps
      else
        IO.warn(
          "Empty Background encountered: #{acc.feature_file}:#{b.location.line}:#{b.location.column}"
        )

        []
      end

    steps
    |> Enum.reduce(acc, fn
      %Step{} = step, a -> MainTraverser.run(step, a, parse_tree)
    end)
  end

  defp background_meta(background, acc) do
    background_key =
      if Map.has_key?(acc.extra, :rule) do
        :background_rule
      else
        :background
      end

    background_details = %{
      name: :background,
      type: background_key,
      title: background.name,
      location: Map.from_struct(background.location),
      keyword: background.keyword
    }

    context_history = acc.extra.context_history

    %{
      :context_history => [background_details | context_history],
      background_key => background_details
    }
  end
end
