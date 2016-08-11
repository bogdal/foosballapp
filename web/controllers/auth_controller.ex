defmodule Foosball.AuthController do
  require Logger
  use Foosball.Web, :controller

  alias Foosball.Team
  alias Foosball.Slack

  def oauth(conn, %{"code" => code}) do
    body = Slack.fetch("https://slack.com/api/oauth.access", %{
      client_id: System.get_env("SLACK_CLIENT_ID"),
      client_secret: System.get_env("SLACK_CLIENT_SECRET"),
      code: code,
      redirect_uri: conn |> get_url(auth_path(conn, :oauth))})
    conn
    |> verify_body(body)
    |> handle_body(body)
    |> put_flash(:info, "You have been authenticated")
    |> redirect(to: page_path(conn, :index))
  end

  def oauth(conn, _params) do
    url = Slack.get_url("https://slack.com/oauth/authorize", %{
        client_id: System.get_env("SLACK_CLIENT_ID"),
        redirect_url: conn |> get_url,
        scope: "commands, chat:write:bot"})
    redirect conn, external: url
  end

  defp verify_body(conn, body) do
      if body["ok"] do
        conn
      else
        conn
        |> put_flash(:error, body["error"] || "Something went wrong")
        |> redirect(to: page_path(conn, :index))
      end
  end

  defp handle_body(conn, body) do
    team =
      Team
      |> Repo.get_by(team_id: body["team_id"])
    if team do
      changeset = Team.changeset(team, %{
        access_token: body["access_token"]})
      Repo.update(changeset)
    else
      changeset = Team.changeset(%Team{}, %{
        team_id: body["team_id"],
        access_token: body["access_token"]})
      Repo.insert(changeset)
    end
    conn
  end

  defp get_url(conn, path \\ "") do
    "https://" <> conn.host <> path
  end
end
