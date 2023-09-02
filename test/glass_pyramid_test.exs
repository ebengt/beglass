defmodule Beglass.PyramidTest do
  use ExUnit.Case

  test "start top glass" do
    {:ok, pid} = Beglass.Pyramid.start_link(%{rows: 1, measuring_glass: 1})

    result = Beglass.Pyramid.glasses(pid)
    result2 = Beglass.Pyramid.liquid(pid)

    assert result2 === 0
    assert Enum.count(result) === 1
    result = Map.keys(result)
    assert result === [{1, 1}]
  end

  test "start row 2" do
    {:ok, pid} = Beglass.Pyramid.start_link(%{rows: 2, measuring_glass: 2})

    result = Beglass.Pyramid.glasses(pid)

    assert Enum.count(result) === 3
    result = Map.keys(result)
    assert Enum.member?(result, {1, 1})
    assert Enum.member?(result, {2, 1})
    assert Enum.member?(result, {2, 2})
  end

  test "start row 3" do
    {:ok, pid} = Beglass.Pyramid.start_link(%{rows: 3})

    result = Beglass.Pyramid.glasses(pid)

    assert Enum.count(result) === 6
    result = Map.keys(result)
    assert Enum.member?(result, {1, 1})
    assert Enum.member?(result, {2, 1})
    assert Enum.member?(result, {2, 2})
    assert Enum.member?(result, {3, 1})
    assert Enum.member?(result, {3, 2})
    assert Enum.member?(result, {3, 3})
  end

  test "start row 4" do
    {:ok, pid} = Beglass.Pyramid.start_link(%{rows: 4, measuring_glass: 3})

    result = Beglass.Pyramid.glasses(pid)

    result = Map.keys(result)
    assert Enum.count(result) === 10
    assert Enum.member?(result, {1, 1})
    assert Enum.member?(result, {2, 1})
    assert Enum.member?(result, {2, 2})
    assert Enum.member?(result, {3, 1})
    assert Enum.member?(result, {3, 2})
    assert Enum.member?(result, {3, 3})
    assert Enum.member?(result, {4, 1})
    assert Enum.member?(result, {4, 2})
    assert Enum.member?(result, {4, 3})
    assert Enum.member?(result, {4, 4})
  end

  test "fill glass" do
    {:ok, pid} = Beglass.Pyramid.start_link(%{rows: 1, measuring_glass: 1})

    Beglass.Pyramid.add_liquid(pid)
    result = Beglass.Pyramid.liquid(pid)
    result2 = Beglass.Pyramid.time(pid)

    assert result2 === 1
    assert result === 1
  end

  test "overflow glass" do
    {:ok, pid} = Beglass.Pyramid.start_link(%{rows: 1, measuring_glass: 1})

    Beglass.Pyramid.add_liquid(pid, 11)

    result =
      receive do
        {:overflow, pid} -> Beglass.Pyramid.position(pid)
      after
        1000 -> :error
      end

    assert result === {1, 1}
  end
end
