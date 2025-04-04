defmodule Sumup.Sorter do
  alias Sumup.Lib.Graph
  alias Sumup.Lib.TopologicalAlgorithm

  @moduledoc """
  Module for sorting tasks in order of execution based on their dependencies.
  """

  @doc """
  Sort tasks based on their dependencies.

  Returns:
  - `{:ok, ordered_tasks}` - If tasks can be ordered successfully
  - `{:error, :circular_dependency}` - If circular dependencies are detected
  - `{:error, :missing_task, task_name}` - If a required task is missing
  """
  def sort([]), do: {:ok, []}

  def sort(tasks) do
    # Build a map of task name to task for quick lookup
    task_map = Map.new(tasks, &{&1["name"], &1})

    try do
      {dependency_graph, incoming_edges} = Graph.build_dependencies(tasks, task_map)

      roots = Graph.find_root_nodes(incoming_edges)

      case TopologicalAlgorithm.sort(dependency_graph, incoming_edges, roots) do
        {:ok, ordered_names} ->
          # Convert ordered names back to full task objects
          ordered_tasks = Enum.map(ordered_names, &Map.get(task_map, &1))
          {:ok, ordered_tasks}

        {:error, reason} ->
          {:error, reason}
      end
    catch
      {:error, :missing_task, task_name} -> {:error, :missing_task, task_name}
    end
  end
end
