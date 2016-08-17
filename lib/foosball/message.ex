defmodule Foosball.Message do

  def update_title(message, text) do
    if String.length(text) > 0 do
      Map.put(message, :text, "<!here> #{text}")
    else
      message
    end
  end

  def update_players(message, players) do
    if length(players) > 0 do
      fields = %{
        fields: [%{
          title: "Players",
          value: players |> join_names}]}
    else
      fields = %{fields: []}
    end
    message
    |> Map.put(:attachments, [hd(message[:attachments]) |> Map.merge(fields)])
  end

  def team_collected(message, players) do
    if length(players) == 4 do
      message = %{
        response_type: "in_channel",
        delete_original: true}
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

  def join_names(names) do
    names
    |> Enum.map(fn n -> "<@#{n}>" end)
    |> Enum.join(", ")
  end
end
