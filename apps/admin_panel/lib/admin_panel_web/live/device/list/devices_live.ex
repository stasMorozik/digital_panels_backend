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

    socket = assign(socket, :devices, [])

    socket = assign(socket, :access_token, access_token)

    socket = assign(socket, :csrf_token, csrf_token)

    socket = assign(socket, :page, 1)

    socket = assign(socket, :limit, 10)

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

    timer = Process.send_after(self(), :get_list, 500)

    {:ok, socket}
  end

  def handle_info(:get_list, socket) do
    fun_success = fn (devices) ->
      socket = assign(socket, :devices, devices)

      {:noreply, socket}
    end

    fun_error = fn (message) ->
      socket = assign(socket, :alert, message)

      socket = assign(socket, :success, false)

      {:noreply, socket}
    end

    filter = %{}

    sort =%{}
    
    pagi = %{page: 1, limit: 10}

    args = %{
      token: socket.assigns.access_token,
      pagi: pagi,
      filter: filter,
      sort: sort
    }

    get_playlist(args, fun_success, fun_error)
  end

  def handle_event("open_filter", form, socket) do
    socket = assign(socket, :is_showed_filter_form, form["is_open"] == "true")

    [{_, "", old_form}] = :ets.lookup(:filter_devices_forms, form["csrf_token"])

    socket = assign(socket, :form, to_form(old_form))

    {:noreply, socket}
  end

  def handle_event("change_filtration_form", form, socket) do
    new_form = Map.drop(form, ["_target", "access_token", "csrf_token"])

    :ets.insert(:filter_devices_forms, {form["csrf_token"], "", new_form})

    {:noreply, socket}
  end

  def handle_event("filter", form, socket) do
    fun_success = fn (devices) ->
      [{_, "", old_form}] = :ets.lookup(:filter_devices_forms, form["csrf_token"])

      socket = assign(socket, :form, to_form(old_form))

      socket = assign(socket, :devices, devices)

      {:noreply, socket}
    end

    fun_error = fn (message) ->
      [{_, "", old_form}] = :ets.lookup(:filter_devices_forms, form["csrf_token"])

      socket = assign(socket, :alert, message)

      socket = assign(socket, :success, false)

      socket = assign(socket, :form, to_form(old_form))

      {:noreply, socket}
    end

    filter = %{
      address: form["filter_by_address"],
      ssh_host: form["filter_by_ssh_host"],
      is_active: form["filter_by_is_active"],
      created_f: form["filter_by_created_f"],
      created_t: form["filter_by_created_t"],
    }

    sort = %{
      is_active: form["sort_by_is_active"],
      created: form["sort_by_created"],
    }

    pagi = %{
      page: 1,
      limit: 10
    }

    args = %{
      token: socket.assigns.access_token,
      pagi: pagi,
      filter: filter,
      sort: sort
    }

    get_playlist(args, fun_success, fun_error)
  end

  def handle_event("page_next", form, socket) do
    socket = assign(socket, :is_showed_filter_form, socket.assigns.is_showed_filter_form)

    [{_, "", old_form}] = :ets.lookup(:filter_devices_forms, form["csrf_token"])
    
    socket = assign(socket, :page, String.to_integer(form["page"]) + 1)

    socket = assign(socket, :form, to_form(old_form))

    {:noreply, socket}
  end

  defp get_playlist(args, fun_success, fun_error) do
    case Core.Device.UseCases.GettingList.get(
      Core.User.UseCases.Authorization,
      PostgresqlAdapters.User.GettingById,
      PostgresqlAdapters.Device.GettingList,
      args
    ) do
      {:ok, devices} -> 
        fun_success.(devices)

      {:error, message} -> 
        fun_error.(message)
    end
  end
end
