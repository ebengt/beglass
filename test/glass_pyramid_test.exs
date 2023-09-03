defmodule Beglass.PyramidTest do
  use ExUnit.Case

  test "start top glass" do
    {:ok, pid} = Beglass.Pyramid.start_link(%{rows: 1})

    result = Beglass.Pyramid.glasses(pid)
    result2 = Beglass.Pyramid.liquid(pid)

    assert result2 === 0
    assert Enum.count(result) === 1
    result = Map.keys(result)
    assert result === [{1, 1}]
  end

  test "start row 2" do
    {:ok, pid} = Beglass.Pyramid.start_link(%{rows: 2})

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
    {:ok, pid} = Beglass.Pyramid.start_link(%{rows: 4})

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
    {:ok, pid} = Beglass.Pyramid.start_link(%{rows: 1})

    Beglass.Pyramid.add_liquid(pid)
    result = Beglass.Pyramid.liquid(pid)
    result2 = Beglass.Pyramid.time(pid)

    assert result2 === 1
    assert result === 1
  end

  test "add liquid" do
    {:ok, pid} = Beglass.Pyramid.start_link(%{rows: 1})
    Beglass.Pyramid.add_liquid(pid, 2)
    Beglass.Pyramid.add_liquid(pid, 3)

    result = Beglass.Pyramid.liquid(pid)

    assert result === 5
  end

  test "overflow glass" do
    {:ok, pid} = Beglass.Pyramid.start_link(%{rows: 1})

    Beglass.Pyramid.add_liquid(pid, 11)

    result =
      receive do
        {:overflow, pid, time} -> {Beglass.Pyramid.position(pid), time}
      after
        1000 -> :error
      end

    assert result === {{1, 1}, 1}
  end

  test "spill over" do
    {:ok, pid} = Beglass.Pyramid.start_link(%{rows: 2})
    Beglass.Pyramid.add_liquid(pid, 11)
    Beglass.Pyramid.add_liquid(pid, 2)
    glasses = Beglass.Pyramid.glasses(pid)
    pid1 = Map.get(glasses, {2, 1})
    pid2 = Map.get(glasses, {2, 2})

    result1 = Beglass.Pyramid.liquid(pid1)
    result2 = Beglass.Pyramid.liquid(pid2)

    assert result1 === 1.5
    assert result1 === result2
  end

  test "time" do
    {:ok, pid} = Beglass.Pyramid.start_link(%{rows: 2})
    Beglass.Pyramid.add_liquid(pid, 2)
    Beglass.Pyramid.add_liquid(pid, 11)
    glasses = Beglass.Pyramid.glasses(pid)
    pid1 = Map.get(glasses, {2, 1})
    pid2 = Map.get(glasses, {2, 2})

    result = Beglass.Pyramid.time(pid)
    result1 = Beglass.Pyramid.time(pid1)
    result2 = Beglass.Pyramid.time(pid2)

    assert result === 2
    assert result === result1
    assert result1 === result2
  end
end
