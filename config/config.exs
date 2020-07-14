import Config

config :utils, :debug_options_file, "#{File.cwd!()}/debug_options.exs"
config :ex_debugger, :debug_options_file, "#{File.cwd!()}/debug_options.exs"

gherkin_languages = "gherkin-languages"

config :ex_gherkin,
  file: %{
    source: "#{gherkin_languages}.json",
    resource: "#{gherkin_languages}.few.terms"
  },
  homonyms: ["Агар ", "* ", "अनी ", "Tha ", "Þá ", "Ða ", "Þa "],
  debug: %{
    tokenizer: false,
    prepare: false,
    parser: false,
    format_message: false,
    parser_raise: false
  }

config :ex_cucumber,
  feature_dir: "#{File.cwd!()}/apps/ex_cucumber/test/support/features",
  project_root: File.cwd!(),
  macro_style: :module, # [:def, :module]
  error_detail_level: :verbose, # [:brief, :verbose]
  placeholder: "This is to serve as a placeholder"
