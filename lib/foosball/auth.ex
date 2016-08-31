defmodule Foosball.SlackAuth do

  alias Foosball.SlackConfig

  @auth_url "https://slack.com/oauth/authorize"
  @access_url "https://slack.com/api/oauth.access"

  def get_auth_url(params) do
    params =
      params
      |> Map.merge(%{
        client_id: SlackConfig.get(:client_id),
        scope: SlackConfig.get(:scope)})
    get_url @auth_url, params
  end

  def fetch(params) do
    params =
      params
      |> Map.merge(%{
        client_id: SlackConfig.get(:client_id),
        client_secret: SlackConfig.get(:client_secret)})
    url = get_url @access_url, params

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
