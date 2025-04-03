defmodule SumupTest do
  use ExUnit.Case, async: true

  @tasks [
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

  describe "process/1" do
    test "processes tasks in correct order based on dependencies" do
      {:ok, ordered_tasks} = Sumup.process(@tasks, :json)

      assert ordered_tasks == [
               %{"name" => "task-1", "command" => "touch /tmp/file1"},
               %{
                 "name" => "task-3",
                 "command" => "echo 'Hello World!' > /tmp/file1",
                 "requires" => ["task-1"]
               },
               %{
                 "name" => "task-2",
                 "command" => "cat /tmp/file1",
                 "requires" => ["task-3"]
               },
               %{
                 "name" => "task-4",
                 "command" => "rm /tmp/file1",
                 "requires" => ["task-2", "task-3"]
               }
             ]
    end

    test "processes tasks in correct order based on dependencies and converts to bash script" do
      {:ok, script} = Sumup.process(@tasks, :bash)

      assert script ==
               """
               #!/usr/bin/env bash
               touch /tmp/file1
               echo 'Hello World!' > /tmp/file1
               cat /tmp/file1
               rm /tmp/file1
               """
               |> String.trim_trailing()
    end
  end
end
