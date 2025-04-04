defmodule SumupWeb.HealthCheckController do
  use SumupWeb, :controller

  def index(conn, _) do
    conn
    |> put_status(:ok)
    |> json(%{status: :ok})
  end
end
