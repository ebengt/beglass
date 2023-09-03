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
    IO.puts("#{:escript.script_name()} rows glass")
    IO.puts("Rows and glass starts at 1. Glass from the left.")
    IO.puts("Example:\n #{:escript.script_name()} 3 2")
  end

  def main([rows, glass]),
    do: config(String.to_integer(rows), String.to_integer(glass)) |> start()

  #
  # Internal functions
  #

  defp add_liquid(config, glass) do
    Beglass.Pyramid.add_liquid(glass)

    receive do
      {:overflow, pid, time} ->
        position = Beglass.Pyramid.position(pid)
        IO.puts("overflow #{time} #{Kernel.inspect(position)}")
        target_exit( config, position)
    after
      1 -> :next
    end

    add_liquid(config, glass)
  end

  defp config(rows, glass) when rows < 1 or glass < 1 or rows < glass,
    do: Kernel.exit("Wrong arguments: #{rows} #{glass}")

  defp config(rows, glass), do: %{rows: rows, glass: glass}

  defp start(config) do
    {:ok, pid} = Beglass.Pyramid.start_link(config)
    add_liquid(config, pid)
  end

  defp target_exit(%{rows: r, glass: g}, {row, glass} ) when row === r and glass === g,
    do: Kernel.exit("Target glass overflowed")

  defp target_exit(_, _), do: :continue
end
