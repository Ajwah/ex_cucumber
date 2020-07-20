defmodule ExCucumber.CucumberExpression do
  @moduledoc false

  defstruct formulation: "",
            meta: nil

  alias __MODULE__.Meta

  def new(expression, caller_env = %Macro.Env{}, gherkin_keyword, id_prefix \\ "") do
    {:ok, meta} = Meta.new(caller_env, gherkin_keyword, id_prefix)

    struct!(__MODULE__, %{
      formulation: expression,
      meta: meta
    })
  end

  def parse([]), do: %{}

  def parse([cucumber_expression = %__MODULE__{}]),
    do:
      CucumberExpressions.parse(cucumber_expression.formulation, %{}, cucumber_expression.meta.id)

  def parse([hd | tl]) do
    parse_tree_so_far =
      tl
      |> Enum.reduce(%{}, fn e = %__MODULE__{}, a ->
        CucumberExpressions.parse(e.formulation, a, e.meta.id).result
      end)

    CucumberExpressions.parse(hd.formulation, parse_tree_so_far, hd.meta.id)
  end
end
