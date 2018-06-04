defmodule HormexTest do
  use ExUnit.Case
  doctest Hormex

  test "greets the world" do
    assert Hormex.hello() == :world
  end
end
