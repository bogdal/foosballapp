defmodule Foosball.SlackController do
  require Logger
  use Foosball.Web, :controller

  alias Foosball.Team
  alias Foosball.Slack

  def index(conn, _params) do
    conn
    |> Slack.request_data
    |> Slack.verify_token
    |> handle_request

    text conn, ""
  end

  defp handle_request(data) do
    message = %{
      response_type: "in_channel",
      text: "<!here> Who wants to play :soccer:?",
      attachments: [%{
          fallback: "You are unable to play",
          callback_id: "foosball_game",
          color: "#3AA3E3",
          attachment_type: "default",
          actions: [%{
              name: "Join / Leave",
              text: "Join / Leave",
              type: "button",
              value: "add"}]}]}
    case data do
      {:command, params} ->
        Logger.debug("Command '#{params["command"]}'")
        message
        |> Slack.update_title(params["text"])
        |> Slack.add_player(params["user_name"])
        |> Slack.send(params["response_url"])
      {:message, params} ->
        for action <- params["actions"] do
          Logger.debug("Action '#{action["value"]}'")
          message
          |> Slack.add_player(params["user_name"])
          |> Slack.send(params["response_url"])
        end
    end
  end
end
