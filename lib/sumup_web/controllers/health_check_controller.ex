defmodule SumupWeb.HealthCheckController do
  @moduledoc """
  This module defines a controller for health check endpoints.
  It provides a simple endpoint to check the health of the application.
  """

  use SumupWeb, :controller

  def index(conn, _) do
    conn
    |> put_status(:ok)
    |> json(%{status: :ok})
  end
end
