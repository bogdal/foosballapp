defmodule Foosball.SlackController do
  require Logger
  use Foosball.Web, :controller

  alias Foosball.Team
  alias Foosball.Slack

  def index(conn, _params) do
    conn
    |> request_data
    |> verify_token
    |> handle_request

    text conn, ""
  end

  defp request_data(conn) do
    if conn.params["payload"] do
      {:message, conn.params["payload"] |> Poison.decode!}
    else
      {:command, conn.params}
    end
  end

  defp verify_token(data) do
    case data do
      {_, params} ->
        if params["token"] == System.get_env("SLACK_VERIFICATION_TOKEN") do
          data
        end
    end
  end

  defp handle_request(data) do
    case data do
      {:command, params} ->
        message
        |> add_player(params["user_name"])
        |> Slack.send(params["response_url"])
      {:message, params} ->
        Logger.debug("handle message")
    end
  end

  defp message() do
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
  end

  defp add_player(message, player) do
    message
  end

end
