defmodule AdminPanelWeb.DevicesLive do
  use AdminPanelWeb, :live_view

  def mount(_params, session, socket) do
    socket = assign(socket, :current_page, "devices")

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
      <div class="flex flex-row items-center">
        <h2 class="mr-10 text-lg text-black">Список устройств</h2>
        <AdminPanelWeb.Components.Presentation.Hrefs.ButtonDefault.c href="/device/new" text="Добавить устройство"/>
      </div>
    """
  end
end
