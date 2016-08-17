defmodule Foosball.SlackAuth do

  alias Foosball.Slack

  def get_auth_url(params) do
    params =
      params
      |> Map.merge(%{
        client_id: Slack.config(:client_id),
        scope: Slack.config(:scope)})
    get_url "https://slack.com/oauth/authorize", params
  end

  def fetch(params) do
    params =
      params
      |> Map.merge(%{
        client_id: Slack.config(:client_id),
        client_secret: Slack.config(:client_secret)})
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

  defp get_url(url, params) do
    url <> "?" <> Plug.Conn.Query.encode(params)
  end
end
