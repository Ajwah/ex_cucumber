import Config

config :utils, :debug_options_file, "#{File.cwd!()}/debug_options.exs"
config :ex_debugger, :debug_options_file, "#{File.cwd!()}/debug_options.exs"
