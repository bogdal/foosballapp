defmodule Foosball.PageController do
  use Foosball.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
