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

    socket = assign(socket, :csrf_token, csrf_token)

    socket = assign(socket, :is_showed_filter_form, false)

    :ets.insert(:filter_devices_forms, {csrf_token, "", %{
      "filter_by_address": nil,
      "filter_by_ssh_host": nil,
      "filter_by_created_f": nil,
      "filter_by_created_t": nil,
      "filter_by_is_active": nil,
      "sort_by_is_active": nil,
      "sort_by_created": nil
    }})

    socket = assign(socket, :form, to_form(%{
      "filter_by_address": "",
      "filter_by_ssh_host": "",
      "filter_by_created_f": "",
      "filter_by_created_t": "",
      "filter_by_is_active": "",
      "sort_by_is_active": "",
      "sort_by_created": ""
    }))

    {:ok, socket}
  end

  def handle_event("open_filter", form, socket) do
    socket = assign(socket, :is_showed_filter_form, form["is_open"] == "true")

    [{_, "", old_form}] = :ets.lookup(:filter_devices_forms, form["csrf_token"])

    IO.inspect(old_form)

    socket = assign(socket, :form, to_form(old_form))

    {:noreply, socket}
  end

  def handle_event("change_filtration_form", form, socket) do
    new_form = Map.drop(form, ["_target", "access_token", "csrf_token"])

    :ets.insert(:filter_devices_forms, {form["csrf_token"], "", new_form})

    {:noreply, socket}
  end
end
