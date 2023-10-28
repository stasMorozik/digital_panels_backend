defmodule AdminPanelWeb.DevicesLive do
  use AdminPanelWeb, :live_view

  use Phoenix.Component
  use Phoenix.HTML

  def mount(_params, session, socket) do
    csrf_token = Map.get(session, "_csrf_token", "")

    [{_, "", access_token}] = :ets.lookup(:access_tokens, csrf_token)

    socket = assign(socket, :current_page, "devices")

    socket = assign(socket, :alert, nil)

    socket = assign(socket, :success, nil)

    socket = assign(socket, :access_token, access_token)

    socket = assign(socket, :is_showed_filter_form, false)

    socket = assign(socket, :form, to_form(%{
      "filter_by_address": nil,
      "filter_by_ssh_host": nil,
      "filter_by_created_f": nil,
      "filter_by_created_t": nil,
      "filter_by_is_active": nil,
      "sort_by_is_active": nil,
      "sort_by_created": nil
    }))

    {:ok, socket}
  end

  def handle_event("open_filter", form, socket) do
    socket = assign(socket, :is_showed_filter_form, form["is_open"] == "true")

    {:noreply, socket}
  end

  def handle_event("test", form, socket) do
    # socket = assign(socket, :is_showed_filter_form, form["is_open"] == "true")

    IO.inspect(form)

    {:noreply, socket}
  end
end
