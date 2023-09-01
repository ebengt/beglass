defmodule BeglassTest do
  use ExUnit.Case
  doctest Beglass

  test "greets the world" do
    assert Beglass.hello() == :world
  end
end
