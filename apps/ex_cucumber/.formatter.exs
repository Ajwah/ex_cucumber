locals_without_parens = [
  _: 2,
  _: 3,
  defgiven: 2,
  defgiven: 3,
  defand: 2,
  defand: 3,
  defthen: 2,
  defthen: 3,
  defbut: 2,
  defbut: 3,
  defwhen: 2,
  defwhen: 3
]

[
  locals_without_parens: locals_without_parens,
  inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}"],
  export: [
    [
      locals_without_parens: locals_without_parens
    ]
  ]
]
