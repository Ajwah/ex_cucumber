import Config

config :ex_debugger, :debug_options_file, "#{File.cwd!()}/debug_options.exs"

gherkin_languages = "gherkin-languages"

config :ex_gherkin,
  file: %{
    source: "#{File.cwd!()}/#{gherkin_languages}.json",
    resource: "#{File.cwd!()}/#{gherkin_languages}.few.terms"
  },
  homonyms: ["Агар ", "* ", "अनी ", "Tha ", "Þá ", "Ða ", "Þa "],
  debug: %{
    tokenizer: false,
    prepare: false,
    parser: false,
    format_message: false,
    parser_raise: false
  }

cwd = File.cwd!() |> String.split("apps") |> List.first

config :ex_cucumber,
  feature_dir: "#{cwd}/apps/ex_cucumber/test/support/features",
  project_root: File.cwd!(),
  # [:def, :module]
  macro_style: :module,
  # [:brief, :verbose]
  error_detail_level: :verbose,
  best_practices: %{
    disallow_gherkin_token_usage_mismatch?: false
  },
  placeholder: "This is to serve as a placeholder"

  IO.inspect("RUNNING")
