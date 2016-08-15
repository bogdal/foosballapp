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
        |> Slack.update_title(params["text"])
        |> Slack.update_players([params["user_name"]])
        |> Slack.send(params["response_url"])
      {:message, params} ->
        for action <- params["actions"] do
          Logger.debug("Action '#{action["value"]}'")
          players =
            Slack.get_players(params["original_message"])
            |> Slack.add_or_remove_player(params["user"]["name"])
          message
          |> Slack.update_players(players)
          |> Slack.team_collected(players)
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
                      value: team1 |> Slack.join_names,
                      short: true}, %{
                      title: "Team 2",
                      value: team2 |> Slack.join_names,
                      short: true}]}]}
            message
            |> Slack.chat_post_message
          end
        end
    end
  end
end
