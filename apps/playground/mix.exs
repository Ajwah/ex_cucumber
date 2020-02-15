defmodule Playground.MixProject do
  use Mix.Project

  def project do
    [
      app: :playground,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:benchee, "~> 1.0", only: :dev},
      {:puid, "~> 1.0"},
      {:crypto_rand, "~> 1.0"},
      {:entropy_string, "~> 1.3", only: :test},
      {:not_qwerty123, "~> 2.3", only: :test},
      {:misc_random, "~> 0.2", only: :test},
      {:rand_str, "~> 1.0", only: :test},
      {:randomizer, "~> 1.1", only: :test},
      {:secure_random, "~> 0.5", only: :test},
      {:uuid, "~> 1.1", only: :test}
    ]
  end
end
