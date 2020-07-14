import Config

# config :cucumber_expressions, :debug,
#   all: false,
#   "Elixir.CucumberExpressions.Matcher": false,
#   "Elixir.CucumberExpressions.Matcher.Submatcher": false,
#   "Elixir.CucumberExpressions.Parser": false,
#   "Elixir.CucumberExpressions.ParameterType.Disambiguator": false,
#   "Elixir.CucumberExpressions.Parser.ParseTree": false

config :ex_debugger, :meta_debug,
  all: %{show_module_tokens: false, show_tokenizer: false, show_ast_before: false, show_ast_after: false},
  "Elixir.CucumberExpressions.Matcher": {false, false, false, false}

config :ex_debugger, :debug,
  capture: :repo, #[:repo, :stdout, :both]
  all: false,
  "Elixir.CucumberExpressions.Parser": false,
  "Elixir.CucumberExpressions.Matcher": false,
  "Elixir.CucumberExpressions.Matcher.Submatcher": false,
  placeholder: false

config :ex_debugger, :manual_debug,
  capture: :stdout, #[:repo, :stdout, :both]
  all: false,
  "Elixir.ExCucumber.Gherkin": false,
  placeholder: false
