defmodule P.LeadingSpaces do
  @text String.duplicate(" ", 10) <> String.duplicate("a", 10_000)
  @opts [
    warmup: 4,
    parallel: 1,
    time: 30,
    memory_time: 30,
    measure_function_call_overhead: true,
    formatters: [Benchee.Formatters.Console],
    print: [
      benchmarking: true,
      configuration: true,
      fast_warning: true
    ]
  ]

  def run do
    Benchee.run(
      %{
        "recursion.return_full" => fn -> v1(@text) end,
        "recursion.return_spaces_size_onle" => fn -> v2(@text) end
      },
      @opts
    )
  end

  def v1(str) do
    {_sentence, _leading_spaces} = v1(str, 0)
  end

  def v1(<<" ", rest::binary>>, num_spaces), do: v1(rest, num_spaces + 1)
  def v1(rest, num_spaces), do: {rest, String.duplicate(" ", num_spaces)}

  def v2(str) do
    spaces_size = v2(str, 0)
    <<_leading_spaces::size(spaces_size), _sentence::binary>> = str
  end

  def v2(<<" ", rest::binary>>, num_spaces), do: v2(rest, num_spaces + 1)
  def v2(rest, num_spaces), do: num_spaces * 8
end

P.LeadingSpaces.run()
