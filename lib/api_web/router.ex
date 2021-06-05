defmodule ApiWeb.Router do
  use ApiWeb, :router
  alias ApiWeb.Plugs.VerifyHeader

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :api_auth do
    plug(VerifyHeader, realm: "Bearer")
  end

  scope "/", ApiWeb do
    scope "/api", Api, as: :api do
      pipe_through :api

      post("/registration", RegistrationController, :create)
      post("/authentication", AuthenticationController, :create)

      # Secure API
      pipe_through(:api_auth)
      patch("/authentication/refresh", AuthenticationController, :refresh)
      delete("/authentication", AuthenticationController, :delete)
    end
  end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).

  # if Mix.env() in [:dev, :test] do
  #   import Phoenix.LiveDashboard.Router

  #   scope "/" do
  #     pipe_through [:fetch_session, :protect_from_forgery]
  #     live_dashboard "/dashboard", metrics: ApiWeb.Telemetry
  #   end
  # end

  scope "/", ApiWeb do
    get("/*path", PageController, :index)
  end
end
