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

    b.steps
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

    %{
      background_key => %{
        title: background.name,
        location: Map.from_struct(background.location),
        keyword: background.keyword
      }
    }
  end
end
