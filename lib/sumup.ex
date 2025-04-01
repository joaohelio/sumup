defmodule Sumup do
  @moduledoc """
  Sumup keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  alias Sumup.Sorter
  alias Sumup.Parser

  @doc """
  Process tasks based on the format.

  ## Examples

      iex> Sumup.process(tasks, :json)
      {:ok, ordered_tasks}
  """
  def process(tasks, :json) do
    Sorter.sort(tasks)
  end

  def process(tasks, :bash) do
    Sorter.sort(tasks)
    |> case do
      {:ok, ordered_tasks} -> {:ok, Parser.to_bash_script(ordered_tasks)}
      error -> {:error, error}
    end
  end
end
