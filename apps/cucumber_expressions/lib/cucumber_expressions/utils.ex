defmodule CucumberExpressions.Utils do
  @moduledoc false

  alias __MODULE__.{
    Random
  }

  defdelegate id, to: Random
  defdelegate id(a), to: Random

  def strip_leading_space(word, _n \\ 1) do
    word
    |> case do
      <<" ", remainder::binary>> -> remainder
      w -> w
    end
  end

  def strip_cwd(file_path, project_root) when is_binary(file_path) do
    file_path
    |> String.replace(project_root, "")
    |> String.trim_leading("/")
  end
end
