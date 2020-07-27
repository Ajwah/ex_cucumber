defmodule ExCucumber.CucumberExpression do
  @moduledoc false

  defstruct formulation: "",
            meta: nil,
            length: 0

  alias __MODULE__.Meta

  def new(expression, caller_env = %Macro.Env{}, gherkin_keyword, id_prefix \\ "") do
    {:ok, meta} = Meta.new(caller_env, gherkin_keyword, id_prefix)

    struct!(__MODULE__, %{
      formulation: expression,
      meta: meta,
      length: String.length(expression)
    })
  end

  def parse([]), do: %{}

  def parse([cucumber_expression = %__MODULE__{}]),
    do:
      CucumberExpressions.parse(cucumber_expression.formulation, %{}, cucumber_expression.meta.id)

  def parse(ls) do
    ls
    # This sorting is introduced on account of the limitation as documented under: test "Subsentence ascending ordering matters" do
    |> Enum.sort(fn a = %__MODULE__{}, b = %__MODULE__{} ->
      a.length <= b.length
    end)
    |> Enum.reduce(%{}, fn e = %__MODULE__{}, a ->
      CucumberExpressions.parse(e.formulation, a, e.meta.id).result
    end)
    |> CucumberExpressions.Parser.result()
  end
end
