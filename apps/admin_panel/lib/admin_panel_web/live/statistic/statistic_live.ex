defmodule AdminPanelWeb.StatisticLive do
  use AdminPanelWeb, :live_view

  def mount(_params, session, socket) do
    socket = assign(socket, :current_page, "statistic")

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""

    """
  end
end
