defmodule ExCucumber.MixProject do
  use Mix.Project

  @vsn "0.1.0"
  @github "https://github.com/Ajwah/ex_cucumber/tree/master/apps/ex_cucumber"
  @name "ExCucumber"

  def project do
    [
      app: :ex_cucumber,
      version: @vsn,
      description: "Parse and match Cucumber Expressions",
      package: %{
        licenses: ["Apache-2.0"],
        source_url: @github,
        links: %{"GitHub" => @github}
      },
      docs: [
        main: @name,
        extras: ["README.md"]
      ],
      aliases: [docs: &build_docs/1],
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.9",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {ExCucumber.Application, []}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/helpers"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:cucumber_expressions, in_umbrella: true},
      # {:cucumber_expressions, "~> 0.1.0"},
      # {:ex_debugger, "0.1.3"},
      {:ex_debugger, path: "/Users/kevinjohnson/projects/ex_debugger", override: true},
      {:ex_gherkin, path: "/Users/kevinjohnson/projects/ex_gherkin", override: true}
      # {:ex_gherkin, "0.1.2"}
    ]
  end

  defp build_docs(_) do
    Mix.Task.run("compile")
    ex_doc = Path.join(Mix.path_for(:escripts), "ex_doc")

    unless File.exists?(ex_doc) do
      raise "cannot build docs because escript for ex_doc is not installed"
    end

    args = [@name, @vsn, Mix.Project.compile_path()]
    opts = ~w[--main #{@name} --source-ref v#{@vsn} --source-url #{@github}]
    System.cmd(ex_doc, args ++ opts)
    Mix.shell().info("Docs built successfully")
  end
end
