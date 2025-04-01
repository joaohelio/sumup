defmodule SumupWeb.Router do
  use SumupWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", SumupWeb do
    pipe_through :api
  end
end
