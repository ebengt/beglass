defmodule Beglass do
  @moduledoc """
  Documentation for `Beglass`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Beglass.hello()
      :world

  """
  def hello do
    :world
  end

  @doc """
  main

  """
  def main([]) do
    IO.puts("#{:escript.script_name()} rows glass add_liquid_0_to_1")
    IO.puts("Rows and glass starts at 1. Glass from the left.")
    IO.puts("Example:\n #{:escript.script_name()} 3 2 1.0")
  end

  def main([rows, glass, add_liquid]),
    do:
      config(String.to_integer(rows), String.to_integer(glass), String.to_float(add_liquid))
      |> start()

  #
  # Internal functions
  #

  defp add_liquid(%{add_liquid: amount} = config, glass) do
    Beglass.Pyramid.add_liquid(glass, amount)

    receive do
      {:overflow, pid, time} ->
        position = Beglass.Pyramid.position(pid)
        IO.puts("overflow #{time} #{Kernel.inspect(position)}")
        target_exit(config, position)
    after
      1 -> :next
    end

    add_liquid(config, glass)
  end

  defp config(rows, glass, add_liquid)
       when rows < 1 or glass < 1 or rows < glass or not is_float(add_liquid),
       do: Kernel.exit("Wrong arguments: #{rows} #{glass}")

  defp config(rows, glass, add_liquid), do: %{rows: rows, glass: glass, add_liquid: add_liquid}

  defp start(config) do
    {:ok, pid} = Beglass.Pyramid.start_link(config)
    add_liquid(config, pid)
  end

  defp target_exit(%{rows: r, glass: g}, {row, glass}) when row === r and glass === g,
    do: Kernel.exit("Target glass overflowed")

  defp target_exit(_, _), do: :continue
end
