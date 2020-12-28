defmodule EverjamWeb.DashboardController do
  use EverjamWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html", cameras: Everjam.cameras())
  end

  def new(conn, _param) do
    render(conn, "new.html")
  end

  def create(conn, %{"url" => url, "username" => username, "password" => password, "auth" => auth} = _params) do
    Everjam.create_camera(url, username, password, auth)
    conn
    |> put_flash(:info, "Camera added successfully.")
    |> redirect(to: "/")
  end

  def show(conn, %{"camera_name" => _camera_name} = _params) do
    # Everjam.start_live_view(camera_name)
    render(conn, "show.html")
  end
end
