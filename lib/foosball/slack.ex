defmodule Foosball.Slack do

  alias Foosball.SlackConfig

  @post_message_url "https://slack.com/api/chat.postMessage"

  def request_data(conn) do
    if conn.params["payload"] do
      {:message, conn.params["payload"] |> Poison.decode!}
    else
      {:command, conn.params}
    end
  end

  def verify_token(data) do
    {_, params} = data
    if params["token"] == SlackConfig.get(:verification_token) do
      data
    else
      {:error, "Invalid token"}
    end
  end

  def send(message, url) do
    encoded_message = Poison.encode!(message)
    HTTPoison.post url, encoded_message
  end

  def chat_post_message(message) do
    params = %{message | attachments: Poison.encode!(message[:attachments])}
    headers = %{"Content-type": "application/x-www-form-urlencoded"}
    HTTPoison.post @post_message_url, params_to_body(params), headers
  end

  defp params_to_body(params) do
    params
    |> Enum.map(fn {key, value} -> "#{key}=#{URI.encode_www_form(value)}" end)
    |> Enum.join("&")
  end
end
