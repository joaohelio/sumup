defmodule Sumup.Lib.TopologicalAlgorithm do
  @moduledoc """
  Uses Kahn's algorithm for topological sorting to determine the correct execution order.
  """

  @doc """
  Perform Kahn's algorithm for topological sorting.

  Returns:
  - `{:ok, ordered_list}` - If sort is successful
  - `{:error, :circular_dependency}` - If circular dependencies are detected
  """
  def sort(dependency_graph, incoming_edges, roots) do
    kahn_sort(dependency_graph, incoming_edges, roots, [])
  end

  defp kahn_sort(_graph, incoming_edges, [], result) do
    # Check if we've visited all nodes
    if Enum.all?(incoming_edges, fn {_node, count} -> count == 0 end) do
      {:ok, Enum.reverse(result)}
    else
      # If there are still nodes with incoming edges, we have a cycle
      {:error, :circular_dependency}
    end
  end

  defp kahn_sort(graph, incoming_edges, [node | rest], result) do
    # Get nodes that depend on this one
    dependents = Map.get(graph, node, [])

    # Update incoming edges for dependent nodes
    {incoming_edges, new_roots} =
      Enum.reduce(dependents, {incoming_edges, []}, fn dep, {edges, new_roots} ->
        # Decrement incoming edge count
        new_count = Map.get(edges, dep) - 1
        edges = Map.put(edges, dep, new_count)

        # If node now has no incoming edges, add to roots
        new_roots = if new_count == 0, do: [dep | new_roots], else: new_roots

        {edges, new_roots}
      end)

    # Continue with updated roots list and result
    kahn_sort(graph, incoming_edges, rest ++ new_roots, [node | result])
  end
end
