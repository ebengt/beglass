defmodule Beglass.GlassPyramidTest do
  use ExUnit.Case

  test "start top glass" do
    {:ok, pid} = Beglass.GlassPyramid.start_link(%{rows: 1, measuring_glass: 1})

    result = Beglass.GlassPyramid.positions(pid)

    assert Enum.count(result) === 1
    assert result === [{1, 1}]
  end

  test "start row 2" do
    {:ok, pid} = Beglass.GlassPyramid.start_link(%{rows: 2, measuring_glass: 2})

    result = Beglass.GlassPyramid.positions(pid)

    assert Enum.count(result) === 3
    assert Enum.member?(result, {1, 1})
    assert Enum.member?(result, {2, 1})
    assert Enum.member?(result, {2, 2})
  end

  test "start row 3" do
    {:ok, pid} = Beglass.GlassPyramid.start_link(%{rows: 3, measuring_glass: 1})

    result = Beglass.GlassPyramid.positions(pid)
    result2 = Beglass.GlassPyramid.measuring_glass(pid)

    assert result2 === {3, 1}
    assert Enum.count(result) === 6
    assert Enum.member?(result, {1, 1})
    assert Enum.member?(result, {2, 1})
    assert Enum.member?(result, {2, 2})
    assert Enum.member?(result, {3, 1})
    assert Enum.member?(result, {3, 2})
    assert Enum.member?(result, {3, 3})
  end

  test "start row 4" do
    {:ok, pid} = Beglass.GlassPyramid.start_link(%{rows: 4, measuring_glass: 3})

    result = Beglass.GlassPyramid.positions(pid)
    result2 = Beglass.GlassPyramid.measuring_glass(pid)

    assert result2 === {4, 3}
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
end
