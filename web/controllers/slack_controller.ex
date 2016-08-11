defmodule Foosball.SlackController do
  require Logger
  use Foosball.Web, :controller

  alias Foosball.Team

  def index(conn, _params) do
    Logger.debug "Slack commands/messages"
    redirect conn, to: "/"
  end

  def oauth(conn, %{"code" => code}) do
    params = [
      "client_id": System.get_env("SLACK_CLIENT_ID"),
      "client_secret": System.get_env("SLACK_CLIENT_SECRET"),
      "code": code,
      "redirect_uri": "https://stage.ngrok.io/slack/oauth"
    ]
    case HTTPoison.get("https://slack.com/api/oauth.access?" <> Plug.Conn.Query.encode(params)) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        data =
          body
          |> Poison.decode!
        if data["ok"] do
          team = Team |> Repo.get_by(team_id: data["team_id"])
          if team do
            changeset = Team.changeset(team, %{access_token: data["access_token"]})
            Repo.update(changeset)
          else
            changeset = Team.changeset(%Team{}, %{team_id: data["team_id"], access_token: data["access_token"]})
            Repo.insert(changeset)
          end
          redirect conn, to: "/success"
        else
          redirect conn, to: "/"
        end
      {:error, %HTTPoison.Error{reason: reason}} ->
        redirect conn, to: "/"
    end
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
