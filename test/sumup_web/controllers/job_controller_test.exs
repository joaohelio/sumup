defmodule SumupWeb.JobControllerTest do
  use SumupWeb.ConnCase, async: true

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

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "process_json/2" do
    test "processes tasks in correct order based on dependencies", %{conn: conn} do
      conn = post(conn, "/api/jobs_to_json", tasks: @tasks)

      assert json_response(conn, 200) == [
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
  end

  describe "process_script/2" do
    test "processes tasks in correct order based on dependencies and converts to bash script", %{
      conn: conn
    } do
      conn = post(conn, "/api/jobs_to_script", tasks: @tasks)

      assert text_response(conn, 200) ==
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
