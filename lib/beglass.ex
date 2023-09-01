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

  def main([rows, glass]) do
    config = config(String.to_integer(rows), String.to_integer(glass))
    IO.inspect(config)
  end

  defp config(rows, glass) when rows < 1 or glass < 1 or rows < glass,
    do: Kernel.exit("Wrong arguments: #{rows} #{glass}")

  defp config(rows, glass), do: %{rows: rows, glass: glass}
end
