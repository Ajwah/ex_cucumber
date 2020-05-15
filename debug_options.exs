import Config

config :cucumber_expressions, :debug,
  all: false,
  "Elixir.CucumberExpressions.Matcher": false,
  "Elixir.CucumberExpressions.Matcher.Submatcher": false,
  "Elixir.CucumberExpressions.Parser": false,
  "Elixir.CucumberExpressions.ParameterType.Disambiguator": false,
  "Elixir.CucumberExpressions.Parser.ParseTree": false

config :ex_debugger, :meta_debug,
  all: %{show_module_tokens: true, show_tokenizer: true, show_ast_before: true, show_ast_after: true}

config :ex_debugger, :debug,
  capture: :stdout, #[:repo, :stdout, :both]
  all: true

config :ex_debugger, :manual_debug,
  capture: :stdout, #[:repo, :stdout, :both]
  all: true
