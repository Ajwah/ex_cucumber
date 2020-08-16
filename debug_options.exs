import Config

config :ex_debugger, :meta_debug,
  all: %{show_module_tokens: false, show_tokenizer: false, show_ast_before: false, show_ast_after: false},
  "Elixir.CucumberExpressions.Matcher": {false, false, false, false},
  placeholder: false

config :ex_debugger, :debug,
  capture: :stdout, #[:repo, :stdout, :both]
  all: false,
  "Elixir.CucumberExpressions.Parser": false,
  "Elixir.CucumberExpressions.ParameterType": false,
  "Elixir.CucumberExpressions.Matcher.Submatcher": false,
  "Elixir.CucumberExpressions.ParameterType.Disambiguator": false,
  "Elixir.CucumberExpressions.Parser.ParseTree": false,
  placeholder: false

config :ex_debugger, :manual_debug,
  capture: :stdout, #[:repo, :stdout, :both]
  warn: false,
  all: false,
  "Elixir.ExCucumber.Gherkin.Traverser.Step": false,
  "Elixir.CucumberExpressions.Matcher": false,
  "Elixir.CucumberExpressions.Matcher.Submatcher": false,
  "Elixir.ExCucumber.Exceptions.Messages": false,
  "Elixir.ExCucumber.Config": false,
  placeholder: false
