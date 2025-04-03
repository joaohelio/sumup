defmodule Sumup.Lib.Graph do
  @moduledoc """
  Builds and manages dependency graphs for tasks.
  """

  @doc """
  Builds a dependency graph and incoming edges count map from a list of tasks.

  Returns a tuple of {dependency_graph, incoming_edges_count} where:
  - dependency_graph: Maps each task to a list of tasks that depend on it
  - incoming_edges_count: Maps each task to its number of dependencies

  ## Throws
    - {:error, :missing_task, task_name} if a required dependency doesn't exist
  """
  def build_dependencies(tasks, task_map) do
    tasks
    |> Enum.reduce({%{}, %{}}, fn task, {dependency_graph, incoming_edges} ->
      task_name = task["name"]
      dependencies = task["requires"] || []

      # Validate all dependencies exist
      validate_dependencies(dependencies, task_map)

      # Initialize this task in both maps if not present
      dependency_graph = Map.put_new(dependency_graph, task_name, [])
      incoming_edges = Map.put_new(incoming_edges, task_name, 0)

      # Process each dependency
      dependencies
      |> Enum.reduce({dependency_graph, incoming_edges}, fn dependency, {graph, edges} ->
        # Add this task as a dependent of its dependency
        graph =
          Map.update(graph, dependency, [task_name], fn dependents -> [task_name | dependents] end)

        # Increment incoming edge count for this task
        edges = Map.update(edges, task_name, 1, &(&1 + 1))

        {graph, edges}
      end)
    end)
  end

  @doc """
  Finds all tasks with no dependencies (root nodes).

  ## Returns
    - List of task names that have no dependencies
  """
  def find_root_nodes(incoming_edges) do
    incoming_edges
    |> Enum.filter(fn {_task, count} -> count == 0 end)
    |> Enum.map(fn {task, _} -> task end)
  end

  defp validate_dependencies(dependencies, task_map) do
    Enum.each(dependencies, fn dependency ->
      unless Map.has_key?(task_map, dependency) do
        throw({:error, :missing_task, dependency})
      end
    end)
  end
end
