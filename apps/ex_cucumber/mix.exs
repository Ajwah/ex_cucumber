defmodule ExCucumber.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_cucumber,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {ExCucumber.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:cucumber_expressions, in_umbrella: true},
      {:utils, in_umbrella: true},
      {:ex_debugger, path: "/Users/kevinjohnson/projects/ex_debugger"},
      {:ex_gherkin, path: "/Users/kevinjohnson/projects/ex_gherkin"},
    ]
  end
end
