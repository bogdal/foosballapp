defmodule Foosball.SlackController do
  require Logger
  use Foosball.Web, :controller

  def index(conn, _params) do
    Logger.debug "Slack commands/messages"
    redirect conn, to: "/"
  end

  def oauth(conn, %{"code" => code}) do
    Logger.debug "Logging this text!"

    text conn, "Oauth"
    redirect conn, external: "http://elixir-lang.org/"
  end

  def oauth(conn, _params) do
    params = [
      "client_id": System.get_env("SLACK_CLIENT_ID"),
      "redirect_url": "https://" <> conn.host,
      "scope": "commands, chat:write:bot"
    ]
    auth_url = "https://slack.com/oauth/authorize" <> "?" <> Plug.Conn.Query.encode(params)
    redirect conn, external: auth_url
  end

end
