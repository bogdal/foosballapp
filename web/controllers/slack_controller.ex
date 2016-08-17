defmodule Foosball.SlackController do
  require Logger
  use Foosball.Web, :controller

  alias Foosball.Message
  alias Foosball.Team
  alias Foosball.Slack

  def index(conn, _params) do
    conn
    |> Slack.request_data
    |> Slack.verify_token
    |> handle_async_request

    text conn, ""
  end

  defp handle_async_request(data) do
    Task.async(fn -> handle_request(data) end)
  end

  defp handle_request(data) do
    message = %{
      response_type: "in_channel",
      text: "<!here> Who wants to play :soccer:?",
      attachments: [%{
          fallback: "You are unable to play",
          fields: [],
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
        |> Message.update_title(params["text"])
        |> Message.update_players([params["user_name"]])
        |> Slack.send(params["response_url"])
      {:message, params} ->
        for action <- params["actions"] do
          Logger.debug("Action '#{action["value"]}'")
          players =
            Message.get_players(params["original_message"])
            |> Message.add_or_remove_player(params["user"]["name"])
          {_, title} =
            params["original_message"]["text"]
            |> String.split_at(7)
          message
          |> Message.update_title(title |> String.trim)
          |> Message.update_players(players)
          |> Message.team_collected(players)
          |> Slack.send(params["response_url"])

          if length(players) == 4 do
            team = Team |> Repo.get_by(team_id: params["team"]["id"])
            {team1, team2} =
              players
              |> Enum.shuffle
              |> Enum.split(2)

            message = %{
                token: team.access_token,
                response_type: "in_channel",
                channel: params["channel"]["id"],
                attachments: [%{
                  text: "Alright, let's play :zap:",
                  fallback: "Let's play!",
                  color: "#3AA3E3",
                  fields: [%{
                      title: "Team 1",
                      value: team1 |> Message.join_names,
                      short: true}, %{
                      title: "Team 2",
                      value: team2 |> Message.join_names,
                      short: true}]}]}
            message
            |> Slack.chat_post_message
          end
        end
    end
  end
end
