defmodule SassTest do
  use ExUnit.Case
  doctest Sass

  test "it compiles file read from File.read" do
    {:ok, file} = File.read("test/test.scss")
    IO.puts file
    sass = Sass.compile(file)
    case sass do
      {:ok, css} -> IO.inspect(css) |> to_string()
      {:error, err} -> IO.puts err |> to_string()
    end
  end
end
