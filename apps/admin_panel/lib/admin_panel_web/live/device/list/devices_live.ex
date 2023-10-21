defmodule AdminPanelWeb.DevicesLive do
  use AdminPanelWeb, :live_view

  def mount(_params, session, socket) do
    socket = assign(socket, :current_page, "devices")

    {:ok, socket}
  end
end
