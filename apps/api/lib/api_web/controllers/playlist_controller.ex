defmodule ApiWeb.PlaylistController do
  use ApiWeb, :controller

  def init(conn, _) do
    conn |> put_status(:ok) |> json(true)
  end

  def list(conn, _) do
    conn |> put_status(:ok) |> json(true)
  end
end
