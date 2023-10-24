defmodule AdminPanelWeb.PlaylistsLive do
  use AdminPanelWeb, :live_view

  def mount(_params, session, socket) do
    socket = assign(socket, :current_page, "playlists")

    {:ok, socket}
  end
end
