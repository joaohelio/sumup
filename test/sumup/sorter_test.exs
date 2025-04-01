defmodule Sumup.SorterTest do
  use ExUnit.Case, async: true

  alias Sumup.Sorter

  describe "sort/1" do
    test "sorts tasks in correct order based on dependencies" do
      tasks = [
        %{"name" => "task-1", "command" => "touch /tmp/file1"},
        %{
          "name" => "task-2",
          "command" => "cat /tmp/file1",
          "requires" => ["task-3"]
        },
        %{
          "name" => "task-3",
          "command" => "echo 'Hello World!' > /tmp/file1",
          "requires" => ["task-1"]
        },
        %{
          "name" => "task-4",
          "command" => "rm /tmp/file1",
          "requires" => ["task-2", "task-3"]
        }
      ]

      {:ok, ordered_tasks} = Sorter.sort(tasks)

      # Check the order is correct
      task_names = Enum.map(ordered_tasks, & &1["name"])

      # Basic correctness check
      assert "task-1" == Enum.at(task_names, 0)
      assert "task-4" == Enum.at(task_names, 3)

      # Check dependency satisfaction
      task_1_index = Enum.find_index(task_names, &(&1 == "task-1"))
      task_2_index = Enum.find_index(task_names, &(&1 == "task-2"))
      task_3_index = Enum.find_index(task_names, &(&1 == "task-3"))
      task_4_index = Enum.find_index(task_names, &(&1 == "task-4"))

      assert task_1_index < task_3_index
      assert task_3_index < task_2_index
      assert task_2_index < task_4_index
      assert task_3_index < task_4_index
    end

    test "detects circular dependencies" do
      tasks = [
        %{"name" => "task-1", "command" => "echo 1", "requires" => ["task-3"]},
        %{"name" => "task-2", "command" => "echo 2", "requires" => ["task-1"]},
        %{"name" => "task-3", "command" => "echo 3", "requires" => ["task-2"]}
      ]

      assert {:error, :circular_dependency} = Sorter.sort(tasks)
    end

    test "handles missing dependencies" do
      tasks = [
        %{"name" => "task-1", "command" => "echo 1"},
        %{"name" => "task-2", "command" => "echo 2", "requires" => ["task-nonexistent"]}
      ]

      assert {:error, :missing_task, "task-nonexistent"} = Sorter.sort(tasks)
    end

    test "handles empty task list" do
      assert {:ok, []} = Sorter.sort([])
    end

    test "handles tasks with no dependencies" do
      tasks = [
        %{"name" => "task-1", "command" => "echo 1"},
        %{"name" => "task-2", "command" => "echo 2"},
        %{"name" => "task-3", "command" => "echo 3"}
      ]

      {:ok, ordered_tasks} = Sorter.sort(tasks)
      assert length(ordered_tasks) == 3

      # Order doesn't matter since there are no dependencies
      task_names = Enum.map(ordered_tasks, & &1["name"])
      assert Enum.sort(task_names) == Enum.sort(["task-1", "task-2", "task-3"])
    end
  end
end
