defmodule Foosball.Router do
  use Foosball.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :slack do
    plug :accepts, ["html"]
  end

  scope "/", Foosball do
    pipe_through :browser

    get "/slack/oauth/", AuthController, :oauth
    get "/", PageController, :index
  end

  scope "/slack", Foosball do
    pipe_through :slack

    post "/", SlackController, :index
  end
end
