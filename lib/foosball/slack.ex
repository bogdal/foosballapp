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

  def update_title(message, text) do
    if String.length(text) > 0 do
      Map.put(message, :text, "<!here> #{text}")
    else
      message
    end
  end

  def get_players(message) do
    field_value =
      message
      |> Map.get("attachments")
      |> hd
      |> Map.get("fields", [%{}])
      |> hd
      |> Map.get("value", "")

    Regex.scan(~r/(?<=@)\w+/, field_value)
    |> List.flatten
  end

  def add_or_remove_player(players, name) do
    if name in players do
      players
      |> List.delete(name)
    else
      players
      |> List.insert_at(-1, name)
    end
  end

  def update_players(message, players) do
    if length(players) > 0 do
      fields = %{
        fields: [%{
          title: "Players",
          value: players |> Enum.map(fn n -> "@#{n}" end) |> Enum.join ", "}]}
    else
      fields = %{fields: []}
    end
    message
    |> Map.put(:attachments, [hd(message[:attachments]) |> Map.merge(fields)])
  end
end
