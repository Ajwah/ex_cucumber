defmodule ExCucumberTest do
  use ExUnit.Case
  doctest ExCucumber

  test "greets the world" do
    assert ExCucumber.hello() == :world
  end
end
