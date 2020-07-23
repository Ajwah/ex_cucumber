import Config

config :ex_debugger, :meta_debug,
  all: %{show_module_tokens: false, show_tokenizer: false, show_ast_before: false, show_ast_after: false},
  placeholder: false

config :ex_debugger, :debug,
  capture: :none,
  all: false,
  placeholder: false

config :ex_debugger, :manual_debug,
  capture: :none,
  warn: false,
  all: false,
  placeholder: false
