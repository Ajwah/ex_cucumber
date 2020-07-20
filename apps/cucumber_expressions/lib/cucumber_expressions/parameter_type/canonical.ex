defmodule CucumberExpressions.ParameterType.Canonical do
  @moduledoc false
  use CucumberExpressions.ParameterType.Base

  def all do
    [
      __MODULE__.Int.meta(),
      __MODULE__.Float.meta(),
      __MODULE__.String.meta(),
      __MODULE__.Word.meta()
    ]
  end
end
