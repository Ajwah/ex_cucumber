defmodule CucumberExpressions.ParserTest do
  @moduledoc false
  use ExUnit.Case

  alias CucumberExpressions.{
    Parser,
    Parser.SyntaxError,
    Utils,
  }

  import TestHelper
  require Parser

  defp format_ending(current_word, original_sentence, incorporate: to_be_incorporated) do
    ""
    |> Parser.new(current_word, original_sentence)
    |> Parser.format_ending(incorporate: to_be_incorporated)
  end

  defp format_ending(current_word, original_sentence) do
    ""
    |> Parser.new(current_word, original_sentence)
    |> Parser.format_ending()
  end

  defp format_ending(original_sentence) do
    ""
    |> Parser.new("", original_sentence)
    |> Parser.format_ending()
  end

  describe "CucumberExpressions.Parser.new produces record" do
    test "sets default vals" do
      p = Parser.new("a", "b", "c")

      assert Parser.parser(p, :remaining_sentence) == "a"
      assert Parser.parser(p, :current_word) == "b"
      assert Parser.parser(p, :original_sentence) == "c"

      assert Parser.parser(p, :collected_sentences) == %{}
      assert Parser.parser(p, :"escaped_{?") == false
      assert Parser.parser(p, :"escaped_(?") == false
      assert Parser.parser(p, :only_spaces_so_far?) == false

      assert {:parser, "a", "b", "c", %{}, false, false, false, true, Utils.id(:fixed)} == p
    end

    test "sets vals" do
      p = Parser.new("a", "b", "c", %{a: 1}, Utils.id(:fixed), true, false, true, false)

      assert Parser.parser(p, :remaining_sentence) == "a"
      assert Parser.parser(p, :current_word) == "b"
      assert Parser.parser(p, :original_sentence) == "c"

      assert Parser.parser(p, :collected_sentences) == %{a: 1}
      assert Parser.parser(p, :"escaped_{?") == true
      assert Parser.parser(p, :"escaped_(?") == false
      assert Parser.parser(p, :only_spaces_so_far?) == true

      assert {:parser, "a", "b", "c", %{a: 1}, true, false, true, false, Utils.id(:fixed)} == p
    end
  end

  describe "Basic" do
    test "null case" do
      full_sentence = ""
      assert Parser.run(full_sentence, %{}) == format_ending(full_sentence)
    end

    test "Converts sentence to nested map of words" do
      full_sentence = "This is a sentence"

      expected = %{
        "This" => %{" is" => %{" a" => format_ending(" sentence", full_sentence)}}
      }

      assert expected == Parser.run(full_sentence, %{})
    end

    test "Incorporates sentence into nested map of words" do
      full_sentence = "This is a sentence"
      another_full_sentence = "This is another sentence"

      expected = %{
        "This" => %{
          " is" => %{
            " a" => format_ending(" sentence", full_sentence),
            " another" => format_ending(" sentence", another_full_sentence)
          }
        }
      }

      assert expected ==
               Parser.run(another_full_sentence, %{
                 "This" => %{" is" => %{" a" => format_ending(" sentence", full_sentence)}}
               })
    end

    test "Handles incorporation of sub-sentences" do
      full_sentence = "This is a sentence"
      another_full_sentence = "This is a sentence that continues over the previous sentence"

      expected = %{
        "This" => %{
          " is" => %{
            " a" =>
              format_ending(" sentence", full_sentence,
                incorporate: %{
                  " that" => %{
                    " continues" => %{
                      " over" => %{
                        " the" => %{
                          " previous" => format_ending(" sentence", another_full_sentence)
                        }
                      }
                    }
                  }
                }
              )
          }
        }
      }

      result = %{}
      result = Parser.run(full_sentence, result)
      result = Parser.run(another_full_sentence, result)

      assert expected == result
    end
  end

  describe "Optional Text" do
    test "single occurrence" do
      full_sentence = "Order {int} cucumber(s) for tonight"
      common_section = %{" for" => format_ending(" tonight", full_sentence)}

      expected = %{
        "Order" => %{
          :params => %{
            :next_key => %{
              " cucumber" => :int,
              " cucumbers" => :int,
              p2p: %{}
            },
            :int => %{
              " cucumber" => common_section,
              " cucumbers" => common_section
            }
          }
        }
      }

      assert expected == Parser.run(full_sentence, %{})

      full_sentence1 = "Order {int} cucumber for tonight"
      full_sentence2 = "Order {int} cucumbers for tonight"

      expected = %{
        "Order" => %{
          :params => %{
            :next_key => %{
              " cucumber" => :int,
              " cucumbers" => :int,
              p2p: %{}
            },
            :int => %{
              " cucumber" => %{" for" => format_ending(" tonight", full_sentence1)},
              " cucumbers" => %{" for" => format_ending(" tonight", full_sentence2)}
            }
          }
        }
      }

      result = %{}
      result = Parser.run(full_sentence1, result)
      result = Parser.run(full_sentence2, result)
      assert expected == result
    end

    test "multiple occurrences within single sentence" do
      full_sentence = "Order {int} cucumber(s) for {int} day(s) in a row"
      common_subsection = %{" in" => %{" a" => format_ending(" row", full_sentence)}}

      common_section = %{
        " for" => %{
          :params => %{
            :next_key => %{
              " day" => :int,
              " days" => :int,
              p2p: %{}
            },
            :int => %{" day" => common_subsection, " days" => common_subsection}
          }
        }
      }

      expected = %{
        "Order" => %{
          :params => %{
            :next_key => %{
              " cucumber" => :int,
              " cucumbers" => :int,
              p2p: %{}
            },
            :int => %{
              " cucumber" => common_section,
              " cucumbers" => common_section
            }
          }
        }
      }

      assert expected == Parser.run(full_sentence, %{})
    end
  end

  describe "Alternative Text" do
    test "single occurrence" do
      full_sentence = "Order {int} cucumbers/potatoes for tonight"
      common_section = %{" for" => format_ending(" tonight", full_sentence)}

      expected = %{
        "Order" => %{
          :params => %{
            :next_key => %{
              " cucumbers" => :int,
              " potatoes" => :int,
              p2p: %{}
            },
            :int => %{
              " cucumbers" => common_section,
              " potatoes" => common_section
            }
          }
        }
      }

      assert expected == Parser.run(full_sentence, %{})

      full_sentence1 = "Order {int} cucumbers for tonight"
      full_sentence2 = "Order {int} potatoes for tonight"

      expected = %{
        "Order" => %{
          :params => %{
            :next_key => %{
              " cucumbers" => :int,
              " potatoes" => :int,
              p2p: %{}
            },
            :int => %{
              " cucumbers" => %{" for" => format_ending(" tonight", full_sentence1)},
              " potatoes" => %{" for" => format_ending(" tonight", full_sentence2)}
            }
          }
        }
      }

      result = %{}
      result = Parser.run(full_sentence1, result)
      result = Parser.run(full_sentence2, result)
      assert expected == result
    end

    test "escaped spaces within" do
      full_sentence = "Order {int} small\\ cucumbers/delicious\\ \\ potatoes for tonight"
      common_section = %{" for" => format_ending(" tonight", full_sentence)}

      expected = %{
        "Order" => %{
          :params => %{
            :next_key => %{
              " small cucumbers" => :int,
              " delicious  potatoes" => :int,
              p2p: %{}
            },
            :int => %{
              " small cucumbers" => common_section,
              " delicious  potatoes" => common_section
            }
          }
        }
      }

      assert expected == Parser.run(full_sentence, %{})

      full_sentence1 = "Order {int} small\\ cucumbers for tonight"
      full_sentence2 = "Order {int} delicious\\ \\ potatoes for tonight"

      expected = %{
        "Order" => %{
          :params => %{
            :next_key => %{
              " small cucumbers" => :int,
              " delicious  potatoes" => :int,
              p2p: %{}
            },
            :int => %{
              " small cucumbers" => %{" for" => format_ending(" tonight", full_sentence1)},
              " delicious  potatoes" => %{" for" => format_ending(" tonight", full_sentence2)}
            }
          }
        }
      }

      result = %{}
      result = Parser.run(full_sentence1, result)
      result = Parser.run(full_sentence2, result)
      assert expected == result
    end

    test "long chain" do
      full_sentence = "Order {int} cucumbers/potatoes/tomatoes/carrots/beans for tonight"
      common_section = %{" for" => format_ending(" tonight", full_sentence)}

      expected = %{
        "Order" => %{
          :params => %{
            :next_key => %{
              " cucumbers" => :int,
              " potatoes" => :int,
              " tomatoes" => :int,
              " carrots" => :int,
              " beans" => :int,
              p2p: %{}
            },
            :int => %{
              " cucumbers" => common_section,
              " potatoes" => common_section,
              " tomatoes" => common_section,
              " carrots" => common_section,
              " beans" => common_section
            }
          }
        }
      }

      assert expected == Parser.run(full_sentence, %{})

      full_sentence1 = "Order {int} cucumbers for tonight"
      full_sentence2 = "Order {int} potatoes for tonight"
      full_sentence3 = "Order {int} tomatoes for tonight"
      full_sentence4 = "Order {int} carrots for tonight"
      full_sentence5 = "Order {int} beans for tonight"

      expected = %{
        "Order" => %{
          :params => %{
            :next_key => %{
              " cucumbers" => :int,
              " potatoes" => :int,
              " tomatoes" => :int,
              " carrots" => :int,
              " beans" => :int,
              p2p: %{}
            },
            :int => %{
              " cucumbers" => %{" for" => format_ending(" tonight", full_sentence1)},
              " potatoes" => %{" for" => format_ending(" tonight", full_sentence2)},
              " tomatoes" => %{" for" => format_ending(" tonight", full_sentence3)},
              " carrots" => %{" for" => format_ending(" tonight", full_sentence4)},
              " beans" => %{" for" => format_ending(" tonight", full_sentence5)}
            }
          }
        }
      }

      result = %{}
      result = Parser.run(full_sentence1, result)
      result = Parser.run(full_sentence2, result)
      result = Parser.run(full_sentence3, result)
      result = Parser.run(full_sentence4, result)
      result = Parser.run(full_sentence5, result)
      assert expected == result
    end

    test "multiple occurrences within single sentence" do
      full_sentence = "Order {int} cucumbers/potatoes for {int} days/nights in a row"
      common_subsection = %{" in" => %{" a" => format_ending(" row", full_sentence)}}

      common_section = %{
        " for" => %{
          :params => %{
            :next_key => %{
              " days" => :int,
              " nights" => :int,
              p2p: %{}
            },
            :int => %{" days" => common_subsection, " nights" => common_subsection}
          }
        }
      }

      expected = %{
        "Order" => %{
          :params => %{
            :next_key => %{
              " cucumbers" => :int,
              " potatoes" => :int,
              p2p: %{}
            },
            :int => %{
              " cucumbers" => common_section,
              " potatoes" => common_section
            }
          }
        }
      }

      assert expected == Parser.run(full_sentence, %{})
    end
  end

  describe "Canonical Parameter Types" do
    test "integer" do
      full_sentence = "This is {int} sentence"

      expected = %{
        "This" => %{
          " is" => %{
            params: %{
              int: format_ending(" sentence", full_sentence),
              next_key: %{" sentence" => :int, p2p: %{}}
            }
          }
        }
      }

      assert expected == Parser.run(full_sentence, %{})
    end

    test "float" do
      full_sentence = "This is {float} sentence"

      expected = %{
        "This" => %{
          " is" => %{
            params: %{
              float: format_ending(" sentence", full_sentence),
              next_key: %{" sentence" => :float, p2p: %{}}
            }
          }
        }
      }

      assert expected == Parser.run(full_sentence, %{})
    end

    test "word" do
      full_sentence = "This is {word} sentence"

      expected = %{
        "This" => %{
          " is" => %{
            params: %{
              word: format_ending(" sentence", full_sentence),
              next_key: %{" sentence" => :word, p2p: %{}}
            }
          }
        }
      }

      assert expected == Parser.run(full_sentence, %{})
    end

    test "string" do
      full_sentence = "This is {string} sentence"

      expected = %{
        "This" => %{
          " is" => %{
            params: %{
              string: format_ending(" sentence", full_sentence),
              next_key: %{" sentence" => :string, p2p: %{}}
            }
          }
        }
      }

      assert expected == Parser.run(full_sentence, %{})
    end

    test "any" do
      full_sentence = "This is {} sentence"

      expected = %{
        "This" => %{
          " is" => %{
            params: %{
              any: format_ending(" sentence", full_sentence),
              next_key: %{" sentence" => :any, p2p: %{}}
            }
          }
        }
      }

      assert expected == Parser.run(full_sentence, %{})
    end
  end

  describe "Custom Parameter Types" do
    test "color" do
      full_sentence = "This is {color} sentence"

      expected = %{
        "This" => %{
          " is" => %{
            params: %{
              color: format_ending(" sentence", full_sentence),
              next_key: %{" sentence" => :color, p2p: %{}}
            }
          }
        }
      }

      assert expected == Parser.run(full_sentence, %{})
    end

    test "containing spaces" do
      full_sentence = "This is {int color} sentence"

      expected = %{
        "This" => %{
          " is" => %{
            params: %{
              "int color": format_ending(" sentence", full_sentence),
              next_key: %{" sentence" => :"int color", p2p: %{}}
            }
          }
        }
      }

      assert expected == Parser.run(full_sentence, %{})
    end
  end

  describe "Several Parameter Types" do
    test "Within one and same sentence" do
      full_sentence = "This is {int} {color} sentence"

      expected = %{
        "This" => %{
          " is" => %{
            params: %{
              next_key: %{p2p: %{color: :int}},
              int: %{
                params: %{
                  next_key: %{" sentence" => :color, p2p: %{}},
                  color: format_ending(" sentence", full_sentence)
                }
              }
            }
          }
        }
      }

      assert expected == Parser.run(full_sentence, %{})
    end

    test "Within one and same sentence consisting of only param types" do
      full_sentence = "{a} {b} {c} {d} {e}"

      expected = %{
        params: %{
          next_key: %{p2p: %{b: :a}},
          a: %{
            params: %{
              next_key: %{p2p: %{c: :b}},
              b: %{
                params: %{
                  next_key: %{p2p: %{d: :c}},
                  c: %{
                    params: %{
                      next_key: %{p2p: %{e: :d}},
                      d: %{
                        params: Map.put(format_ending(:e, full_sentence), :next_key, %{end: :e})
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }

      assert expected == Parser.run(full_sentence, %{})
    end

    test "Over multiple but same sentence" do
      full_sentence = "This is {int} {color} sentence"

      expected = %{
        "This" => %{
          " is" => %{
            params: %{
              next_key: %{
                p2p: %{color: :int}
              },
              int: %{
                params: %{
                  next_key: %{
                    " sentence" => :color,
                    p2p: %{}
                  },
                  color: format_ending(" sentence", full_sentence)
                }
              }
            }
          }
        }
      }

      result = %{}
      result = Parser.run(full_sentence, result)
      result = Parser.run(full_sentence, result)
      result = Parser.run(full_sentence, result)
      result = Parser.run(full_sentence, result)
      result = Parser.run(full_sentence, result)
      result = Parser.run(full_sentence, result)

      assert expected == result
    end

    test "Over different sentences" do
      full_sentence1 = "{string} this sentence"
      full_sentence2 = "This is {int} sentence"
      full_sentence3 = "This is {int} {color} sentence"
      full_sentence4 = "This sentence is {word}"
      full_sentence5 = "This {int} sentence is {color}"

      expected = %{
        :params => %{
          next_key: %{
            " this" => :string,
            p2p: %{}
          },
          string: %{" this" => format_ending(" sentence", full_sentence1)}
        },
        "This" => %{
          :params => %{
            :next_key => %{
              " sentence" => :int,
              p2p: %{}
            },
            :int => %{
              " sentence" => %{
                " is" => %{
                  :params =>
                    Map.put(format_ending(:color, full_sentence5), :next_key, %{end: :color})
                }
              }
            }
          },
          " sentence" => %{
            " is" => %{
              :params => Map.put(format_ending(:word, full_sentence4), :next_key, %{end: :word})
            }
          },
          " is" => %{
            :params => %{
              :next_key => %{
                " sentence" => :int,
                p2p: %{color: :int}
              },
              :int =>
                %{
                  :params => %{
                    :next_key => %{
                      " sentence" => :color,
                      p2p: %{}
                    },
                    :color => format_ending(" sentence", full_sentence3)
                  }
                }
                |> Map.merge(format_ending(" sentence", full_sentence2))
            }
          }
        }
      }

      result = %{}
      result = Parser.run(full_sentence1, result)
      result = Parser.run(full_sentence2, result)
      result = Parser.run(full_sentence3, result)
      result = Parser.run(full_sentence4, result)
      result = Parser.run(full_sentence5, result)

      assert expected == result
    end

    test "Over different sentences with repetition" do
      full_sentence1 = "{string} this sentence"
      full_sentence2 = "This is {int} sentence"
      full_sentence3 = "This is {int} {color} sentence"
      full_sentence4 = "This sentence is {word}"
      full_sentence5 = "This {int} sentence is {color}"

      expected = %{
        :params => %{
          next_key: %{
            " this" => :string,
            p2p: %{}
          },
          string: %{" this" => format_ending(" sentence", full_sentence1)}
        },
        "This" => %{
          :params => %{
            :next_key => %{
              " sentence" => :int,
              p2p: %{}
            },
            :int => %{
              " sentence" => %{
                " is" => %{
                  :params =>
                    Map.put(format_ending(:color, full_sentence5), :next_key, %{end: :color})
                }
              }
            }
          },
          " sentence" => %{
            " is" => %{
              :params => Map.put(format_ending(:word, full_sentence4), :next_key, %{end: :word})
            }
          },
          " is" => %{
            :params => %{
              :next_key => %{
                " sentence" => :int,
                p2p: %{color: :int}
              },
              :int =>
                %{
                  :params => %{
                    :next_key => %{
                      " sentence" => :color,
                      p2p: %{}
                    },
                    :color => format_ending(" sentence", full_sentence3)
                  }
                }
                |> Map.merge(format_ending(" sentence", full_sentence2))
            }
          }
        }
      }

      result = %{}
      result = Parser.run(full_sentence1, result)
      result = Parser.run(full_sentence1, result)
      result = Parser.run(full_sentence1, result)
      result = Parser.run(full_sentence2, result)
      result = Parser.run(full_sentence3, result)
      result = Parser.run(full_sentence5, result)
      result = Parser.run(full_sentence1, result)
      result = Parser.run(full_sentence1, result)
      result = Parser.run(full_sentence2, result)
      result = Parser.run(full_sentence2, result)
      result = Parser.run(full_sentence2, result)
      result = Parser.run(full_sentence2, result)
      result = Parser.run(full_sentence4, result)
      result = Parser.run(full_sentence5, result)
      result = Parser.run(full_sentence5, result)

      assert expected == result
    end
  end

  describe "Intertwined Parameter Types" do
    test "All in same point" do
      full_sentence1 = "This is {int} sentence"
      full_sentence2 = "This is {float} sentence"
      full_sentence3 = "This is {word} sentence"
      full_sentence4 = "This is {string} sentence"
      full_sentence5 = "This is {} sentence"

      expected = %{
        "This" => %{
          " is" => %{
            params: %{
              next_key: %{
                " sentence" => [:any, :string, :word, :float, :int],
                p2p: %{}
              },
              int: format_ending(" sentence", full_sentence1),
              float: format_ending(" sentence", full_sentence2),
              word: format_ending(" sentence", full_sentence3),
              string: format_ending(" sentence", full_sentence4),
              any: format_ending(" sentence", full_sentence5)
            }
          }
        }
      }

      result = %{}
      result = Parser.run(full_sentence1, result)
      result = Parser.run(full_sentence2, result)
      result = Parser.run(full_sentence3, result)
      result = Parser.run(full_sentence4, result)
      result = Parser.run(full_sentence5, result)

      assert expected == result
    end
  end

  describe "White-spaces" do
    test "in beginning" do
      full_sentence = " This is a sentence"

      expected = %{
        " This" => %{" is" => %{" a" => format_ending(" sentence", full_sentence)}}
      }

      result = %{}
      result = Parser.run(full_sentence, result)
      assert expected == result

      full_sentence = "  This is a sentence"

      expected = %{
        "  This" => %{" is" => %{" a" => format_ending(" sentence", full_sentence)}}
      }

      result = %{}
      result = Parser.run(full_sentence, result)
      assert expected == result
    end

    test "at ending" do
      full_sentence = "This is a sentence "

      expected = %{
        "This" => %{" is" => %{" a" => %{" sentence" => format_ending(" ", full_sentence)}}}
      }

      result = %{}
      result = Parser.run(full_sentence, result)
      assert expected == result

      full_sentence = "This is a sentence  "

      expected = %{
        "This" => %{
          " is" => %{" a" => %{" sentence" => format_ending("  ", full_sentence)}}
        }
      }

      result = %{}
      result = Parser.run(full_sentence, result)
      assert expected == result
    end

    test "in middle" do
      full_sentence = "This  is a   sentence"

      expected = %{
        "This" => %{"  is" => %{" a" => format_ending("   sentence", full_sentence)}}
      }

      result = %{}
      result = Parser.run(full_sentence, result)
      assert expected == result

      full_sentence = "This is          a sentence"

      expected = %{
        "This" => %{
          " is" => %{"          a" => format_ending(" sentence", full_sentence)}
        }
      }

      result = %{}
      result = Parser.run(full_sentence, result)
      assert expected == result
    end

    test "anywhere" do
      full_sentence = "   This  is a   sentence   "

      expected = %{
        "   This" => %{
          "  is" => %{" a" => %{"   sentence" => format_ending("   ", full_sentence)}}
        }
      }

      result = %{}
      result = Parser.run(full_sentence, result)
      assert expected == result
    end

    test "multiple sentences" do
      full_sentence1 = "   This  is a   sentence   "
      full_sentence2 = "This  is a   sentence   "
      full_sentence3 = "This  is another   sentence   "
      full_sentence4 = "    a   sentence   this is"

      expected = %{
        "   This" => %{
          "  is" => %{" a" => %{"   sentence" => format_ending("   ", full_sentence1)}}
        },
        "This" => %{
          "  is" => %{
            " a" => %{"   sentence" => format_ending("   ", full_sentence2)},
            " another" => %{"   sentence" => format_ending("   ", full_sentence3)}
          }
        },
        "    a" => %{"   sentence" => %{"   this" => format_ending(" is", full_sentence4)}}
      }

      result = %{}
      result = Parser.run(full_sentence1, result)
      result = Parser.run(full_sentence2, result)
      result = Parser.run(full_sentence3, result)
      result = Parser.run(full_sentence4, result)
      assert expected == result
    end
  end

  describe "Escaping Special Characters" do
    test "\\/" do
      full_sentence = "This  is a   sentence\\/words"

      expected = %{
        "This" => %{
          "  is" => %{" a" => format_ending("   sentence/words", full_sentence)}
        }
      }

      result = %{}
      result = Parser.run(full_sentence, result)
      assert expected == result
    end

    test "\\{" do
      full_sentence = "This  is \\{a}   sentence"

      expected = %{
        "This" => %{
          "  is" => %{" {a}" => format_ending("   sentence", full_sentence)}
        }
      }

      result = %{}
      result = Parser.run(full_sentence, result)
      assert expected == result
    end

    test "\\( \\{" do
      full_sentence = "I have 42 \\{what} cucumber(s) in my belly \\(amazing!)"
      subset = %{" in" => %{" my" => %{" belly" => format_ending(" (amazing!)", full_sentence)}}}

      expected = %{
        "I" => %{
          " have" => %{
            " 42" => %{
              " {what}" => %{
                " cucumber" => subset,
                " cucumbers" => subset
              }
            }
          }
        }
      }

      result = %{}
      result = Parser.run(full_sentence, result)
      assert expected == result
    end
  end

  describe "Mix" do
    test "optionals with alternatives" do
      full_sentence = "1/2 : 3/4 : 5/6(s) : 7(s)/8 : 9/10/11/12"

      subset4 = %{
        " :" =>
          [" 9", " 10", " 11", " 12"]
          |> Enum.reduce(%{}, fn e, a ->
            Map.merge(a, format_ending(e, full_sentence))
          end)
      }

      subset3 = %{
        " :" => %{
          " 7" => subset4,
          " 7s" => subset4,
          " 8" => subset4
        }
      }

      subset2 = %{
        " :" => %{
          " 5" => subset3,
          " 6" => subset3,
          " 6s" => subset3
        }
      }

      subset1 = %{
        " :" => %{
          " 3" => subset2,
          " 4" => subset2
        }
      }

      expected = %{
        "1" => subset1,
        "2" => subset1
      }

      result = %{}
      result = Parser.run(full_sentence, result)
      assert expected == result
    end
  end

  describe "SyntaxErrors" do
    test "Reserved Parameter Name" do
      assert_specific_raise(SyntaxError, :reserved_param, fn ->
        full_sentence = "This is {any} sentence"
        Parser.run(full_sentence, %{})
      end)
    end

    test "Non Closing Parameter" do
      assert_specific_raise(SyntaxError, :non_closing_param, fn ->
        full_sentence = "This is {int sentence"
        Parser.run(full_sentence, %{})
      end)
    end

    test "Non Opening Parameter" do
      assert_specific_raise(SyntaxError, :non_opening_param, fn ->
        full_sentence = "This is int} sentence"
        Parser.run(full_sentence, %{})
      end)
    end

    test "Nested Parameter" do
      assert_specific_raise(SyntaxError, :nested_param, fn ->
        full_sentence = "This is {int{float}} sentence"
        Parser.run(full_sentence, %{})
      end)
    end

    test "Non Closing Optional Text Bracket" do
      assert_specific_raise(SyntaxError, :non_closing_optional_text_bracket, fn ->
        full_sentence = "This is 1( sentence"
        Parser.run(full_sentence, %{})
      end)
    end

    test "Non Opening Optional Text Bracket" do
      assert_specific_raise(SyntaxError, :non_opening_optional_text_bracket, fn ->
        full_sentence = "This is 1) sentence"
        Parser.run(full_sentence, %{})
      end)
    end

    test "Nested Optional Text Bracket" do
      assert_specific_raise(SyntaxError, :nested_optional_text_bracket, fn ->
        full_sentence = "This is 1(s() sentence"
        Parser.run(full_sentence, %{})
      end)
    end
  end
end
