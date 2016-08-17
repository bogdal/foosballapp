defmodule Foosball.Slack do

  def request_data(conn) do
    if conn.params["payload"] do
      {:message, conn.params["payload"] |> Poison.decode!}
    else
      {:command, conn.params}
    end
  end

  def verify_token(data) do
    {_, params} = data
    if params["token"] == config(:verification_token) do
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
    url = "https://slack.com/api/chat.postMessage"
    params = %{message | attachments: Poison.encode!(message[:attachments])}
    HTTPoison.post url, params_to_body(params)
  end

  defp params_to_body(params) do
    params
    |> Enum.map(fn {key, value} -> "#{key}=#{URI.encode_www_form(value)}" end)
    |> Enum.join("&")
  end

  def config(param) do
    Application.get_env(:foosball, :slack)[param]
  end
end
