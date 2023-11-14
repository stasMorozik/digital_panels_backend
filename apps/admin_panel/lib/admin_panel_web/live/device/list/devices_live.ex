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

    socket = assign(socket, :form, to_form(%{
      filter_by_address: "",
      filter_by_ssh_host: "",
      filter_by_created_f: "",
      filter_by_created_t: "",
      filter_by_is_active: "",
      sort_by_is_active: "",
      sort_by_created: ""
    }))

    [{_, "", list}] = :ets.lookup(:admin_sockets, "pids")

    list = list ++ [self()]

    :ets.insert(:admin_sockets, {"pids", "", list})

    timer = Process.send_after(self(), :get_list, 500)

    {:ok, socket}
  end

  def terminate(reason, _socket) do
    [{_, "", list}] = :ets.lookup(:admin_sockets, "pids")

    :ets.insert(:admin_sockets, {"pids", "", list})

    reason
  end

  def handle_info({:change_activity, payload}, socket) do
    devices = Enum.map(socket.assigns.devices, fn (device) ->
      if device.id == payload.id do
        Map.put(device, :is_active, payload.is_active)
      else
        device
      end
    end)

    socket = assign(socket, :devices, devices)

    {:noreply, socket}
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

    sort = %{}
    
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

  def handle_event("open_filter", form, socket) do
    socket = assign(socket, :is_showed_filter_form, form["is_open"] == "true")

    socket = assign(socket, :form, socket.assigns.form)

    {:noreply, socket}
  end

  def handle_event("close_alert", form, socket) do
    socket = assign(socket, :alert, nil)

    socket = assign(socket, :success, nil)

    socket = assign(socket, :form, socket.assigns.form)

    {:noreply, socket}
  end

  def handle_event("change_filtration_form", form, socket) do
    new_form = to_form(%{
      filter_by_address: form["filter_by_address"],
      filter_by_ssh_host: form["filter_by_ssh_host"],
      filter_by_created_f: form["filter_by_created_f"],
      filter_by_created_t: form["filter_by_created_t"],
      filter_by_is_active: form["filter_by_is_active"],
      sort_by_is_active: form["sort_by_is_active"],
      sort_by_created: form["sort_by_created"]
    })

    socket = assign(socket, :form, new_form)

    {:noreply, socket}
  end

  def handle_event("cancel_filter", form, socket) do
    fun_success = fn (devices) ->
      
      socket = assign(socket, :form, to_form(%{
        filter_by_address: "",
        filter_by_ssh_host: "",
        filter_by_created_f: "",
        filter_by_created_t: "",
        filter_by_is_active: "",
        sort_by_is_active: "",
        sort_by_created: ""
      }))

      socket = assign(socket, :devices, devices)

      socket = assign(socket, :is_showed_filter_form, socket.assigns.is_showed_filter_form)

      socket = assign(socket, :page, 1)

      {:noreply, socket}
    end

    fun_error = fn (message) ->
      socket = assign(socket, :alert, message)

      socket = assign(socket, :success, false)

      socket = assign(socket, :form, socket.assigns.form)

      socket = assign(socket, :is_showed_filter_form, socket.assigns.is_showed_filter_form)

      {:noreply, socket}
    end

    filter = %{
      address: nil,
      ssh_host: nil,
      is_active: nil,
      created_f: nil,
      created_t: nil,
    }

    sort = %{
      is_active: nil,
      created: nil,
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

  def handle_event("filter", form, socket) do
    fun_success = fn (devices) ->
      
      socket = assign(socket, :form, socket.assigns.form)

      socket = assign(socket, :devices, devices)

      socket = assign(socket, :is_showed_filter_form, socket.assigns.is_showed_filter_form)

      socket = assign(socket, :page, 1)

      {:noreply, socket}
    end

    fun_error = fn (message) ->
      socket = assign(socket, :alert, message)

      socket = assign(socket, :success, false)

      socket = assign(socket, :form, socket.assigns.form)

      socket = assign(socket, :is_showed_filter_form, socket.assigns.is_showed_filter_form)

      {:noreply, socket}
    end

    filter_by_is_active = get_field_from_form(form, "filter_by_is_active")

    filter_by_is_active = case filter_by_is_active do
      nil -> nil
      string_bool -> string_to_bol(string_bool)
    end

    filter = %{
      address: get_field_from_form(form, "filter_by_address"),
      ssh_host: get_field_from_form(form, "filter_by_ssh_host"),
      is_active: filter_by_is_active,
      created_f: get_field_from_form(form, "filter_by_created_f"),
      created_t: get_field_from_form(form, "filter_by_created_t"),
    }

    sort = %{
      is_active: get_field_from_form(form, "sort_by_is_active"),
      created: get_field_from_form(form, "sort_by_created"),
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
    change_page("page_next", form, socket)
  end

  def handle_event("page_prev", form, socket) do
    case String.to_integer(form["page"]) > 1 do
      true -> change_page("page_prev", form, socket)
      false -> {:noreply, socket}
    end
  end

  defp change_page(action, form, socket) do
    fun_success = fn (devices) ->
      socket = case length(devices) > 0 do
        true ->
          socket = case action do
            "page_next" -> assign(socket, :page, String.to_integer(form["page"]) + 1)
            "page_prev" -> assign(socket, :page, String.to_integer(form["page"]) - 1)
          end

          assign(socket, :devices, devices)
          
        false -> socket
      end

      socket = assign(socket, :form, socket.assigns.form)

      socket = assign(socket, :is_showed_filter_form, socket.assigns.is_showed_filter_form)

      {:noreply, socket}
    end

    fun_error = fn (message) ->
      socket = assign(socket, :alert, message)

      socket = assign(socket, :success, false)

      socket = assign(socket, :is_showed_filter_form, socket.assigns.is_showed_filter_form)

      socket = assign(socket, :form, socket.assigns.form)

      {:noreply, socket}
    end

    filter_by_created_f = socket.assigns.form.params.filter_by_created_f
    
    filter_by_created_f = case Date.from_iso8601(filter_by_created_f) do
      {:ok, filter_by_created_f} -> filter_by_created_f
      {:error, _} -> nil
    end

    filter_by_created_t = socket.assigns.form.params.filter_by_created_t

    filter_by_created_t = case Date.from_iso8601(filter_by_created_t) do
      {:ok, filter_by_created_t} -> filter_by_created_t
      {:error, _} -> nil
    end
    
    filter_by_is_active = get_field_from_form(socket.assigns.form.params, :filter_by_is_active)

    filter_by_is_active = case filter_by_is_active do
      nil -> nil
      string_bool -> string_to_bol(string_bool)
    end

    filter = %{
      address: get_field_from_form(socket.assigns.form.params, :filter_by_address),
      ssh_host: get_field_from_form(socket.assigns.form.params, :filter_by_ssh_host),
      is_active: filter_by_is_active,
      created_f: filter_by_created_f,
      created_t: filter_by_created_t,
    }

    sort = %{
      is_active: get_field_from_form(socket.assigns.form.params, :sort_by_is_active),
      created: get_field_from_form(socket.assigns.form.params, :sort_by_created),
    }

    pagi = %{
      page: case action do 
        "page_next" -> String.to_integer(form["page"]) + 1
        "page_prev" -> String.to_integer(form["page"]) - 1
      end,
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

  defp string_to_bol(str) do
    case str do
      "true" -> true
      "false" -> false
    end
  end

  defp get_field_from_form(form, field) do
    value = form[field]
  
    case value == "" do
      true -> nil
      false -> value
    end 
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
