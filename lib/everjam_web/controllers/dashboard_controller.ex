defmodule EverjamWeb.DashboardController do
  use EverjamWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html", cameras: Everjam.cameras())
  end
end
