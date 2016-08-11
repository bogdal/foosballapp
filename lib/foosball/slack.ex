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
end
