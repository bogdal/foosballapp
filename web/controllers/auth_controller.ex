defmodule Foosball.AuthController do
  require Logger
  use Foosball.Web, :controller

  alias Foosball.Team
  alias Foosball.SlackAuth

  def oauth(conn, %{"code" => code}) do
    data = SlackAuth.fetch(%{
      code: code,
      redirect_uri: conn |> get_host_url(auth_path(conn, :oauth))})
    conn
    |> handle_error(data)
    |> save_access_token(data)
    |> put_flash(:info, "You have been authenticated")
    |> redirect(to: page_path(conn, :index))
  end

  def oauth(conn, _params) do
    url = SlackAuth.get_auth_url(%{redirect_url: conn |> get_host_url})
    redirect conn, external: url
  end

  defp handle_error(conn, data) do
    case data do
      {:ok, _} ->
        conn
      {:error, reason} ->
        conn
        |> put_flash(:error, reason)
        |> redirect(to: page_path(conn, :index))
      end
  end

  defp save_access_token(conn, {_, params}) do
    team =
      Team
      |> Repo.get_by(team_id: params["team_id"])
    if team do
      changeset = Team.changeset(team, %{
        access_token: params["access_token"]})
      Repo.update(changeset)
    else
      changeset = Team.changeset(%Team{}, %{
        team_id: params["team_id"],
        access_token: params["access_token"]})
      Repo.insert(changeset)
    end
    conn
  end

  defp get_host_url(conn, path \\ "") do
    "https://" <> conn.host <> path
  end
end
