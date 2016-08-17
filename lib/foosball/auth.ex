defmodule Foosball.SlackAuth do

  def get_auth_url(params) do
    params =
      params
      |> Map.merge(%{
        client_id: System.get_env("SLACK_CLIENT_ID"),
        scope: "commands, chat:write:bot"})
    get_url "https://slack.com/oauth/authorize", params
  end

  def fetch(params) do
    params =
      params
      |> Map.merge(%{
        client_id: System.get_env("SLACK_CLIENT_ID"),
        client_secret: System.get_env("SLACK_CLIENT_SECRET")})
    url = get_url "https://slack.com/api/oauth.access", params

    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        data =
          body
          |> Poison.decode!
        if data["ok"] do
          {:ok, data}
        else
          {:error, data["error"]}
        end
      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end

  defp get_url(url, params \\ []) do
    url <> "?" <> Plug.Conn.Query.encode(params)
  end
end
