defmodule AdminPanelWeb.DeviceNewLive do
  use AdminPanelWeb, :live_view

  alias Core.User.UseCases.Authorization
  alias PostgresqlAdapters.User.GettingById, as: GettingUser

  alias Core.Device.UseCases.Creating
  alias PostgresqlAdapters.Device.Inserting
  alias PostgresqlAdapters.Playlist.Getting, as: GettingPlaylist

  alias Core.Playlist.UseCases.GettingList, as: GettingListPlaylistUseCase
  alias PostgresqlAdapters.Playlist.GettingList, as: GettingListPlaylistPostgresAdapter

  def mount(_params, session, socket) do
    csrf_token = Map.get(session, "_csrf_token", "")

    [{_, "", access_token}] = :ets.lookup(:access_tokens, csrf_token)

    :ets.insert(:device_new_forms, {csrf_token, "", %{
      "address": nil,
      "ssh_port": nil,
      "ssh_host": nil,
      "ssh_user": nil,
      "ssh_password": nil,
      "longitude": nil,
      "latitude": nil,
      "playlist_id": nil
    }})

    socket = assign(socket, :current_page, "devices")

    socket = assign(socket, :playlists, [])

    socket = assign(socket, :is_open_drop_down, false)

    socket = assign(socket, :success, nil)

    socket = assign(socket, :alert, nil)

    socket = assign(socket, :access_token, access_token)

    socket = assign(socket, :csrf_token, csrf_token)

    socket = assign(socket, :selected_playlist, "")

    socket = assign(socket, :form, to_form(%{
      "address": nil,
      "ssh_port": nil,
      "ssh_host": nil,
      "ssh_user": nil,
      "ssh_password": nil,
      "longitude": nil,
      "latitude": nil,
      "playlist_id": nil
    }))

    socket = assign(socket, :form_searching, to_form(%{
      "searching_value": ""
    }))

    {:ok, socket}
  end

  def handle_event("get_playlists", form, socket) do
    args = %{
      token: socket.assigns.access_token
    }

    fun_success = fn (playlists) -> 
      [{_, "", old_form}] = :ets.lookup(:device_new_forms, form["csrf_token"])

      socket = assign(socket, :form, to_form(old_form))

      socket = assign(socket, :playlists, playlists)

      socket = assign(socket, :is_open_drop_down, true)

      {:noreply, socket}
    end

    fun_error = fn (message) ->
      socket = assign(socket, :success, false)

      socket = assign(socket, :alert, message)

      {:noreply, socket}
    end
    
    get_playlists(args, fun_success, fun_error)
  end

  def handle_event("change_creating_form", form, socket) do
    new_form = Map.drop(form, ["_target", "access_token", "csrf_token"])

    :ets.insert(:device_new_forms, {form["csrf_token"], "", new_form})

    {:noreply, socket}
  end

  def handle_event("change_searching_playlists_form", form, socket) do
    with searching_value = Map.get(form, "searching_value", ""),
         searching_value <- String.trim(searching_value),
         true <- searching_value == "",
         args = %{
          token: socket.assigns.access_token
         },
         fun_success <- fn (playlists) -> 
            [{_, "", old_form}] = :ets.lookup(:device_new_forms, form["csrf_token"])

            socket = assign(socket, :form, to_form(old_form))

            socket = assign(socket, :playlists, playlists)

            {:noreply, socket}
         end,
         fun_error = fn (message) ->
            socket = assign(socket, :success, false)

            socket = assign(socket, :alert, message)

            {:noreply, socket}
         end do
      get_playlists(args, fun_success, fun_error)
    else
      false -> {:noreply, socket}
    end
  end

  def handle_event("search_playlists", form, socket) do
    filter = %{
      name: form["searching_value"]
    }
    
    args = %{
      token: socket.assigns.access_token,
      filter: filter
    }

    fun_success = fn (playlists) -> 
      [{_, "", old_form}] = :ets.lookup(:device_new_forms, form["csrf_token"])

      socket = assign(socket, :form, to_form(old_form))

      socket = assign(socket, :playlists, playlists)

      socket = assign(socket, :form_searching, to_form(form))

      {:noreply, socket}
    end

    fun_error = fn (message) ->
      socket = assign(socket, :success, false)

      socket = assign(socket, :alert, message)

      {:noreply, socket}
    end
    
    get_playlists(args, fun_success, fun_error)
  end

  def handle_event("close_alert", form, socket) do
    socket = assign(socket, :alert, nil)

    socket = assign(socket, :success, nil)

    [{_, "", old_form}] = :ets.lookup(:device_new_forms, form["csrf_token"])

    socket = assign(socket, :form, to_form(old_form))

    {:noreply, socket}
  end

  def handle_event("close_drop_down", form, socket) do
    [{_, "", old_form}] = :ets.lookup(:device_new_forms, form["csrf_token"])

    socket = assign(socket, :form, to_form(old_form))

    socket = assign(socket, :is_open_drop_down, false)

    socket = assign(socket, :form_searching, to_form(%{
      "searching_value": ""
    }))

    {:noreply, socket}
  end

  def handle_event("select_device", form, socket) do
    [{_, "", old_form}] = :ets.lookup(:device_new_forms, form["csrf_token"])

    socket = assign(socket, :is_open_drop_down, false)

    socket = assign(socket, :selected_playlist, form["playlist_name"])

    old_form = Map.put(old_form, "playlist_id", form["playlist_id"])

    socket = assign(socket, :form, to_form(old_form))

    socket = assign(socket, :form_searching, to_form(%{
      "searching_value": ""
    }))

    {:noreply, socket}
  end
  
  defp get_playlists(args, fun_success, fun_error) do
    case GettingListPlaylistUseCase.get(
      Authorization, 
      GettingUser,
      GettingListPlaylistPostgresAdapter,
      args
    ) do
      {:ok, playlists} -> 
        fun_success.(playlists)

      {:error, message} -> 
        fun_error.(message)
    end
  end

  def handle_event("create_device", form, socket) do
    args = %{
      ssh_port: String.to_integer( Map.get(form, "ssh_port", "") ),
      ssh_host: Map.get(form, "ssh_host", ""),
      ssh_user: Map.get(form, "ssh_user", ""),
      ssh_password: Map.get(form, "ssh_password", ""),
      address: Map.get(form, "address", ""),
      longitude: String.to_float(Map.get(form, "longitude", "")),
      latitude: String.to_float(Map.get(form, "latitude", "")),
      playlist_id: Map.get(form, "playlist_id", ""),
      token: Map.get(form, "access_token", "")
    }

    case Creating.create(
      Authorization, 
      GettingUser, 
      GettingPlaylist, 
      Inserting, 
      args
    ) do
      {:ok, _} -> 
        socket = assign(socket, :success, true)
        socket = assign(socket, :alert, "Устройство успешно добавлено")
        socket = assign(socket, :selected_playlist, "")
        socket = assign(socket, :form, to_form(%{
          "address": nil,
          "ssh_port": nil,
          "ssh_host": nil,
          "ssh_user": nil,
          "ssh_password": nil,
          "longitude": nil,
          "latitude": nil,
          "playlist_id": nil
        }))

        :ets.insert(:device_new_forms, {form["csrf_token"], "", %{
          "address": nil,
          "ssh_port": nil,
          "ssh_host": nil,
          "ssh_user": nil,
          "ssh_password": nil,
          "longitude": nil,
          "latitude": nil,
          "playlist_id": nil
        }})

        {:noreply, socket}
      {:error, message} -> 
        [{_, "", old_form}] = :ets.lookup(:device_new_forms, form["csrf_token"])

        socket = assign(socket, :success, false)
        socket = assign(socket, :alert, message)
        socket = assign(socket, :form, to_form(old_form))

        {:noreply, socket}
    end
  end
end
