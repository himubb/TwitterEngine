defmodule Project4Web.Router do
  use Project4Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Project4Web do
    pipe_through :browser

    get "/", PageController, :index
    get "/home", TweetsController, :show
  end

  # Other scopes may use custom stacks.
  # scope "/api", Project4Web do
  #   pipe_through :api
  # end
end
