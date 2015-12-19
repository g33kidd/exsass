defmodule Sass do
  @moduledoc """
    SASS Compiler for Elixir
  """

  def compile(string) do
    string |> String.strip() |> Sass.Compiler.compile
  end
end
