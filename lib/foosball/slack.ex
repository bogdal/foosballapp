defmodule Foosball.Slack do

  def fetch(url, params \\ []) do
    case HTTPoison.get(get_url(url, params)) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        body
        |> Poison.decode!
      {:error, %HTTPoison.Error{reason: reason}} ->
        nil
    end
  end

  def get_url(url, params \\ []) do
    url <> "?" <> Plug.Conn.Query.encode(params)
  end

  def request_data(conn) do
    if conn.params["payload"] do
      {:message, conn.params["payload"] |> Poison.decode!}
    else
      {:command, conn.params}
    end
  end

  def verify_token(data) do
    case data do
      {_, params} ->
        if params["token"] == System.get_env("SLACK_VERIFICATION_TOKEN") do
          data
        end
    end
  end

  def send(message, url) do
    encoded_message = Poison.encode!(message)
    HTTPoison.post(url, encoded_message)
    message
  end

  def add_player(message, player) do
    message
  end
end
