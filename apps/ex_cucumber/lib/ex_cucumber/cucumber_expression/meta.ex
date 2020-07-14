defmodule ExCucumber.CucumberExpression.Meta do
  @moduledoc false

  defstruct [
    id: :abcdef,
    id_str: "",
    module: nil,
    file: "",
    line_nr: 0,
    gherkin_keyword: nil,
  ]

  def new(caller_env = %Macro.Env{}, gherkin_keyword, id_prefix \\ "") do
    id_str = id_prefix <> Utils.id()
    {
      :ok,
      struct!(__MODULE__, %{
        id: id_str |> String.to_atom,
        id_str: id_str,
        file: caller_env.file,
        module: caller_env.module,
        line_nr: caller_env.line,
        gherkin_keyword: gherkin_keyword
      })
    }
  end
end
