defmodule P.Duplicate do
  @char " "
  @num 10
  @opts [
    warmup: 4,
    parallel: 1,
    measure_function_call_overhead: true,
    formatters: [Benchee.Formatters.Console],
    print: [
      benchmarking: true,
      configuration: true,
      fast_warning: true
    ]
    # console: [
    #   comparison: true,
    #   unit_scaling: :best
    # ]
  ]

  def run do
    Benchee.run(
      %{
        "String.duplicate" => fn -> v1(@char, @num) end,
        "recursion" => fn -> v2(@char, @num, "") end
      },
      @opts
    )
  end

  def v1(char, num), do: String.duplicate(char, num)
  def v2(_, 0, acc), do: acc
  def v2(char, num, acc), do: v2(char, num - 1, acc <> char)
end

P.Duplicate.run()
