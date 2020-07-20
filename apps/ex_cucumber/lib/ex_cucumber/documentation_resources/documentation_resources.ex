defmodule ExCucumber.DocumentationResources do
  @moduledoc false
  @todo :to_do_include_link

  @links %{
    worlds_most_misunderstood_collaboration_tool:
      "https://cucumber.io/blog/collaboration/the-worlds-most-misunderstood-collaboration-tool/",
    duplicate_step_definition:
      "https://cucumber.io/docs/community/faq/#duplicate-step-definition",
    gherkin_spec: %{
      homonyms: @todo
    }
  }

  def link(key), do: Map.fetch!(@links, key)
  def link(key, subkey), do: @links |> Map.fetch!(key) |> Map.fetch!(subkey)
end
