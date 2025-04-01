defmodule SumupWeb.Router do
  use SumupWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", SumupWeb do
    pipe_through :api

    post "/jobs_to_json", JobController, :process_json
    post "/jobs_to_script", JobController, :process_script
  end
end
