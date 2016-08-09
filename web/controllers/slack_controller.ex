defmodule Foosball.SlackController do
  use Foosball.Web, :controller

  def index(conn, _params) do
    text conn, "Slack request"
  end

  def oauth(conn, _params) do
    text conn, "Oauth"
  end
end
