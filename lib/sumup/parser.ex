
defmodule Sumup.Parser do
  @doc """
  Convert tasks to a bash script.

  Takes a list of ordered tasks and returns a bash script as a string.
  """
  def to_bash_script(ordered_tasks) do
    ["#!/usr/bin/env bash" | Enum.map(ordered_tasks, & &1["command"])]
    |> Enum.join("\n")
  end
end
