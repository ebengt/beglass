defmodule Beglass.GlassPyramid do
  @moduledoc """
  A glass pyramid with a target glass in the last row.
  """

  def measuring_glass(pid), do: call(pid, {:measuring_glass})
  def positions(pid), do: call(pid, {:position}) |> Enum.uniq()
  def right_glass(pid), do: call(pid, {:right_glass})

  def start_link(%{rows: _, measuring_glass: _} = config) do
    state = init(config, 1, 1)
    Task.start_link(fn -> loop(state) end)
  end

  #
  # Internal functions
  #

  defp call(pid, request) do
    Kernel.send(pid, {:call, Kernel.self(), request})

    receive do
      {^pid, ^request, response} -> response
    end
  end

  defp init(%{rows: r, measuring_glass: mg} = config, row, glass) when row === r do
    config |> Map.put(:position, {row, glass}) |> Map.put(:measuring_glass, mg === glass)
  end

  defp init(config, row, 1) do
    state1 = init(config, row + 1, 1)
    {:ok, pid1} = Task.start_link(fn -> loop(state1) end)
    state2 = config |> Map.put(:left_glass, right_glass(pid1)) |> init(row + 1, 2)
    {:ok, pid2} = Task.start_link(fn -> loop(state2) end)

    config
    |> Map.put(:position, {row, 1})
    |> Map.put(:left_glass, pid1)
    |> Map.put(:right_glass, pid2)
  end

  defp init(%{left_glass: pid1} = config, row, glass) do
    state = config |> Map.put(:left_glass, right_glass(pid1)) |> init(row + 1, glass + 1)
    {:ok, pid2} = Task.start_link(fn -> loop(state) end)
    config |> Map.put(:position, {row, glass}) |> Map.put(:right_glass, pid2)
  end

  defp loop(state) do
    receive do
      {:call, from, request} ->
        Kernel.send(from, {Kernel.self(), request, response(request, state)})
    end

    loop(state)
  end

  defp response({:measuring_glass}, %{measuring_glass: true, position: p}), do: p

  defp response({:measuring_glass}, %{left_glass: pid1, right_glass: pid2}),
    do: measuring_glass(pid1) |> response_measuring_glass(pid2)

  defp response({:measuring_glass}, _), do: nil

  defp response({:position}, %{position: p, left_glass: pid1, right_glass: pid2}),
    do: [p | positions(pid1) ++ positions(pid2)]

  defp response({:position}, %{position: p}), do: [p]

  defp response({:right_glass}, %{right_glass: pid}), do: pid
  defp response({:right_glass}, _state), do: nil

  defp response_measuring_glass(nil, pid2), do: measuring_glass(pid2)
  defp response_measuring_glass(position, _pid2), do: position
end
