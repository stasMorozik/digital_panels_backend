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

    socket = assign(socket, :current_page, "devices")

    socket = assign(socket, :playlists, [])

    socket = assign(socket, :is_open_drop_down, false)

    socket = assign(socket, :success, nil)

    socket = assign(socket, :alert, nil)

    socket = assign(socket, :access_token, access_token)

    socket = assign(socket, :csrf_token, csrf_token)

    socket = assign(socket, :selected_playlist, "")

    socket = assign(socket, :form, to_form(%{
      address: nil,
      ssh_port: nil,
      ssh_host: nil,
      ssh_user: nil,
      ssh_password: nil,
      longitude: nil,
      latitude: nil,
      playlist_id: nil
    }))

    socket = assign(socket, :form_searching, to_form(%{
      searching_value: ""
    }))

    {:ok, socket}
  end

  def handle_event("get_playlists", form, socket) do
    args = %{
      token: socket.assigns.access_token
    }

    fun_success = fn (playlists) -> 
      socket = assign(socket, :form, socket.assigns.form)
      
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

    new_form = to_form(%{
      address: new_form["address"],
      ssh_port: new_form["ssh_port"],
      ssh_host: new_form["ssh_host"],
      ssh_user: new_form["ssh_user"],
      ssh_password: new_form["ssh_password"],
      longitude: new_form["longitude"],
      latitude: new_form["latitude"],
      playlist_id: new_form["playlist_id"]
    })

    socket = assign(socket, :form, new_form)

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
            socket = assign(socket, :form, socket.assigns.form)

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
      socket = assign(socket, :form, socket.assigns.form)

      socket = assign(socket, :playlists, playlists)

      new_form = to_form(%{
        searching_value: form["searching_value"]
      })

      socket = assign(socket, :form_searching, to_form(new_form))

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

    socket = assign(socket, :form, socket.assigns.form)

    {:noreply, socket}
  end

  def handle_event("close_drop_down", form, socket) do
    socket = assign(socket, :form, socket.assigns.form)

    socket = assign(socket, :is_open_drop_down, false)

    socket = assign(socket, :form_searching, to_form(%{
      searching_value: ""
    }))

    {:noreply, socket}
  end

  def handle_event("select_device", form, socket) do
    socket = assign(socket, :is_open_drop_down, false)

    socket = assign(socket, :selected_playlist, form["playlist_name"])

    new_form = to_form(%{
      address: socket.assigns.form.params.address,
      ssh_port: socket.assigns.form.params.ssh_port,
      ssh_host: socket.assigns.form.params.ssh_host,
      ssh_user: socket.assigns.form.params.ssh_user,
      ssh_password: socket.assigns.form.params.ssh_password,
      longitude: socket.assigns.form.params.longitude,
      latitude: socket.assigns.form.params.latitude,
      playlist_id: form["playlist_id"]
    })

    socket = assign(socket, :form, to_form(new_form))

    socket = assign(socket, :form_searching, to_form(%{
      searching_value: ""
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
    ssh_port = case Integer.parse(Map.get(form, "ssh_port", "")) do
      {integer, _} -> integer
      :error -> -1
    end

    longitude = case Integer.parse(Map.get(form, "longitude", "")) do
      {integer, _} -> integer
      :error -> -1
    end

    latitude = case Integer.parse(Map.get(form, "latitude", "")) do
      {integer, _} -> integer
      :error -> -1
    end

    args = %{
      ssh_port: ssh_port,
      ssh_host: Map.get(form, "ssh_host", ""),
      ssh_user: Map.get(form, "ssh_user", ""),
      ssh_password: Map.get(form, "ssh_password", ""),
      address: Map.get(form, "address", ""),
      longitude: longitude,
      latitude: latitude,
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
          address: nil,
          ssh_port: nil,
          ssh_host: nil,
          ssh_user: nil,
          ssh_password: nil,
          longitude: nil,
          latitude: nil,
          playlist_id: nil
        }))

        {:noreply, socket}
      {:error, message} -> 
        socket = assign(socket, :success, false)
        socket = assign(socket, :alert, message)
        socket = assign(socket, :form, socket.assigns.form)

        {:noreply, socket}
    end
  end
end
