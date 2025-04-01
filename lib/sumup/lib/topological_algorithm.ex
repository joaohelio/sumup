defmodule Sumup.Lib.TopologicalAlgorithm do
  @moduledoc """
  Implements Kahn's algorithm for topological sorting to determine correct execution order.
  """

  @doc """
  Performs topological sorting using Kahn's algorithm.

  ## Returns
    * `{:ok, ordered_list}` - When sort is successful
    * `{:error, :circular_dependency}` - When circular dependencies are detected
  """
  def sort(dependency_graph, incoming_edges, roots) do
    kahn_sort(dependency_graph, incoming_edges, roots, [])
  end

  # When no more roots exist, check if we've processed everything
  defp kahn_sort(_graph, incoming_edges, [], result) do
    if all_nodes_processed?(incoming_edges) do
      {:ok, Enum.reverse(result)}
    else
      {:error, :circular_dependency}
    end
  end

  # Process current node and continue with remaining nodes
  defp kahn_sort(graph, incoming_edges, [current_node | remaining_nodes], result) do
    dependents = Map.get(graph, current_node, [])
    {updated_edges, new_roots} = remove_dependencies(dependents, incoming_edges)

    # Continue algorithm with new roots and add current node to result
    kahn_sort(
      graph,
      updated_edges,
      remaining_nodes ++ new_roots,
      [current_node | result]
    )
  end

  defp all_nodes_processed?(incoming_edges) do
    Enum.all?(incoming_edges, fn {_node, count} -> count == 0 end)
  end

  defp remove_dependencies(dependents, incoming_edges) do
    Enum.reduce(dependents, {incoming_edges, []}, fn dependent, {edges, new_roots} ->
      new_count = Map.get(edges, dependent) - 1
      updated_edges = Map.put(edges, dependent, new_count)

      # If node has no more incoming edges, it becomes a new root
      updated_roots = if new_count == 0, do: [dependent | new_roots], else: new_roots

      {updated_edges, updated_roots}
    end)
  end
end
