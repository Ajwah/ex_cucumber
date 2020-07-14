defmodule ExCucumber.Gherkin.Traverser.Ctx do
  @moduledoc false
  alias ExCucumber.Config

  defstruct [
    location: %{},
    feature_file: "",
    module: nil,
    module_file: "",
    token: nil,
    keyword: "",
    extra: %{}
  ]

  def new(feature_file, module, module_file, location \\ :none, keyword \\ "", token \\ :none) do
    struct!(__MODULE__, %{
      feature_file: Utils.strip_cwd(feature_file, Config.project_root),
      module: module,
      module_file: Utils.strip_cwd(module_file, Config.project_root),
      location: location,
      keyword: keyword,
      token: token,
    })
  end

  def location(%__MODULE__{} = m, location = %{column: _, line: _}), do: %{m | location: location}
  def token(%__MODULE__{} = m, token) when is_atom(token) do
    %{m | token: token}
  end
  def keyword(%__MODULE__{} = m, keyword) when is_binary(keyword), do: %{m | keyword: keyword}
  def extra(%__MODULE__{} = m, extra), do: %{m | extra: Map.merge(m.extra, extra)}
  def update(%__MODULE__{} = m, ls) do
    ls
    |> Enum.reduce(m, fn {key, value}, a ->
      apply(__MODULE__, key, [a, value])
    end)
  end


  def module_name(%__MODULE__{} = m), do: m.module |> to_string |> String.trim_leading("Elixir.")
end
