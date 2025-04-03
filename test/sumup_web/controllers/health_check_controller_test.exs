defmodule SumupWeb.HealthCheckControllerTest do
  use SumupWeb.ConnCase, async: true

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "GET /api/healthz" do
    test "returns a 200 status with a JSON response", %{conn: conn} do
      conn = get(conn, "/api/healthz")

      assert json_response(conn, 200) == %{"status" => "ok"}
    end
  end
end
