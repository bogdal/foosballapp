defmodule Foosball.SlackController do
  require Logger
  use Foosball.Web, :controller

  alias Foosball.Team

  def index(conn, _params) do
    Logger.debug "Slack commands/messages"
    redirect conn, to: "/"
  end
end
