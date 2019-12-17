defmodule Project4Web.PageController do
  use Project4Web, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
