defmodule AdminPanelWeb.DevicesLive do
  use AdminPanelWeb, :live_view

  def mount(_params, session, socket) do
    socket = assign(socket, :href, "devices")

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""

    """
  end
end
