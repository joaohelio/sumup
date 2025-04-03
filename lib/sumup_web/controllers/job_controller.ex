defmodule SumupWeb.JobController do
  use SumupWeb, :controller

  def process_json(conn, %{"tasks" => tasks}) do
    case Sumup.process(tasks, :json) do
      {:ok, ordered_tasks} ->
        conn
        |> put_status(:ok)
        |> json(ordered_tasks)

      {:error, error} ->
        conn
        |> put_status(:bad_request)
        |> json(%{"error" => error})
    end
  end

  def process_script(conn, %{"tasks" => tasks}) do
    case Sumup.process(tasks, :bash) do
      {:ok, script} ->
        conn
        |> put_status(:ok)
        |> text(script)

      {:error, error} ->
        conn
        |> put_status(:bad_request)
        |> json(%{"error" => error})
    end
  end
end
