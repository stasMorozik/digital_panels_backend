defmodule AdminPanelWeb.DevicesLive do
  use AdminPanelWeb, :live_view

  def mount(_params, session, socket) do
    csrf_token = Map.get(session, "_csrf_token", "")

    [{_, "", access_token}] = :ets.lookup(:access_tokens, csrf_token)

    socket = assign(socket, :current_page, "devices")

    socket = assign(socket, :alert, nil)

    socket = assign(socket, :success, nil)

    socket = assign(socket, :access_token, access_token)

    socket = assign(socket, :is_showed_filter_form, false)

    socket = assign(socket, :form, to_form(%{
      "address": "",
      "ssh_host": "",
      "created_f": "",
      "created_t": "",
      "is_active": true
    }))

    {:ok, socket}
  end

  def handle_event("open_filter", form, socket) do
    IO.inspect(form)
    socket = assign(socket, :is_showed_filter_form, form["is_open"] == "true")

    {:noreply, socket}
  end
end
