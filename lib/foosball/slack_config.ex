defmodule Foosball.SlackConfig do

  def get(param) do
    Application.get_env(:foosball, :slack)[param]
  end
end
