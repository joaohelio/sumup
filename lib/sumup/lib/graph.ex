defmodule Sumup.Lib.Graph do
  @moduledoc """
  Build both a dependency graph and an incoming edges count map.

  The dependency graph maps each node to its dependent nodes.
  The incoming edges map tracks how many dependencies each node has.
  """

  @doc """
  Build dependency graph and incoming edges count map.
  """
  def build_dependencies(tasks, task_map) do
    tasks
    |> Enum.reduce({%{}, %{}}, fn task, {graph, in_edges} ->
      name = task["name"]
      requires = task["requires"] || []

      # First, validate dependencies exist
      Enum.each(requires, fn req ->
        unless Map.has_key?(task_map, req) do
          throw({:error, :missing_task, req})
        end
      end)

      # Initialize this node in both graphs if not present
      graph = Map.put_new(graph, name, [])
      in_edges = Map.put_new(in_edges, name, 0)

      # Add dependencies
      Enum.reduce(requires, {graph, in_edges}, fn req, {g, e} ->
        # Update dependency graph
        g = Map.update(g, req, [name], fn deps -> [name | deps] end)

        # Update incoming edge count
        e = Map.update(e, name, 1, &(&1 + 1))

        {g, e}
      end)
    end)
  end

  def find_root_nodes(incoming_edges) do
    # Get all nodes that have zero incoming edges
    incoming_edges
    |> Enum.filter(fn {_node, count} -> count == 0 end)
    |> Enum.map(fn {node, _} -> node end)
  end
end
