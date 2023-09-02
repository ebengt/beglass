defmodule Beglass.Pyramid do
  @moduledoc """
  A glass pyramid with a target glass in the last row.
  """

  defstruct [
    :left_glass,
    :position,
    :right_glass,
    liquid: 0,
    overflow: false,
    time: 0,
    volume: 10
  ]

  def add_liquid(pid), do: cast(pid, {:add_liquid, 1})
  def add_liquid(pid, volume), do: cast(pid, {:add_liquid, volume})
  def glasses(pid), do: call(pid, {:glasses})
  def liquid(pid), do: call(pid, {:liquid})
  def position(pid), do: call(pid, {:position})
  def right_glass(pid), do: call(pid, {:right_glass})
  def time(pid), do: call(pid, {:time})

  def start_link(%{rows: r}) do
    state = init(%__MODULE__{}, r, 1, 1)
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

  defp cast(pid, request), do: Kernel.send(pid, {:cast, request})

  defp init(state, rows, row, glass) when rows === row do
    %{state | position: {row, glass}}
  end

  defp init(state, rows, row, 1) do
    state1 = init(state, rows, row + 1, 1)
    {:ok, pid1} = Task.start_link(fn -> loop(state1) end)
    state2 = %{state | left_glass: right_glass(pid1)} |> init(rows, row + 1, 2)
    {:ok, pid2} = Task.start_link(fn -> loop(state2) end)

    %{state | position: {row, 1}, left_glass: pid1, right_glass: pid2}
  end

  defp init(state, rows, row, glass) do
    state2 =
      %{state | left_glass: right_glass(state.left_glass)} |> init(rows, row + 1, glass + 1)

    {:ok, pid2} = Task.start_link(fn -> loop(state2) end)
    %{state | position: {row, glass}, right_glass: pid2}
  end

  defp loop(state) do
    new =
      receive do
        {:call, from, request} ->
          Kernel.send(from, {Kernel.self(), request, response(request, state)})
          state

        {:cast, request} ->
          new_state(request, state)
      end

    loop(new)
  end

  defp new_state({:add_liquid, volume}, state),
    do: %{state | liquid: state.liquid + volume, time: state.time + 1} |> new_state_owerflow()

  defp new_state_owerflow(%{owner: o, volume: v, max: m} = state) when v > m do
    Kernel.send(o, {:overflow, Kernel.self()})
    Map.put(state, :overflow, true)
  end

  defp new_state_owerflow(state), do: state

  defp response({:liquid}, %{liquid: l}), do: l

  defp response({:glasses}, %{left_glass: nil, right_glass: nil} = state),
    do: %{state.position => Kernel.self()}

  defp response({:glasses}, state),
    do:
      %{state.position => Kernel.self()}
      |> Map.merge(glasses(state.left_glass))
      |> Map.merge(glasses(state.right_glass))

  defp response({:position}, %{position: p}), do: p
  defp response({:right_glass}, %{right_glass: pid}), do: pid
  defp response({:right_glass}, _state), do: nil
  defp response({:time}, %{time: l}), do: l
  defp response({:volume}, %{volume: l}), do: l
end
