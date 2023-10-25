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

    socket = assign(socket, :selected_playlist, "")

    socket = assign(socket, :form, to_form(%{
      "address": "",
      "ssh_port": "",
      "ssh_host": "",
      "ssh_user": "",
      "ssh_password": "",
      "longitude": "",
      "latitude": "",
      "playlist_id": ""
    }))

    socket = assign(socket, :form_searching, to_form(%{
      "searching_value": ""
    }))

    {:ok, socket}
  end


  def handle_event("get_playlists", form, socket) do
    with access_token = Map.get(form, "access_token", ""),
         args = Map.put(%{}, :token, access_token),
         {:ok, playlists} <- GettingListPlaylistUseCase.get(
            Authorization, 
            GettingUser,
            GettingListPlaylistPostgresAdapter,
            args
         ) do
      socket = assign(socket, :playlists, playlists)

      socket = assign(socket, :is_open_drop_down, true)

      socket = assign(socket, :form, to_form(form))

      {:noreply, socket}
    else 
      {:error, message} -> 
        socket = assign(socket, :success, false)

        socket = assign(socket, :alert, message)

        socket = assign(socket, :form, to_form(form))

        {:noreply, socket}
    end
  end

  def handle_event("change_for_search_playlists", form, socket) do
    with access_token = Map.get(form, "access_token", ""),
         searching_value = Map.get(form, "searching_value", ""),
         searching_value <- String.trim(searching_value),
         true <- searching_value == "",
         args = Map.put(%{}, :token, access_token),
         {:ok, playlists} <- GettingListPlaylistUseCase.get(
            Authorization, 
            GettingUser,
            GettingListPlaylistPostgresAdapter,
            args
         ) do
      socket = assign(socket, :playlists, playlists)

      {:noreply, socket}
    else
      false -> 
        {:noreply, socket}
      
      {:error, message} -> 
        socket = assign(socket, :success, false)

        socket = assign(socket, :alert, message)

        {:noreply, socket}
    end
  end

  def handle_event("search_playlists", form, socket) do
    with access_token = Map.get(form, "access_token", ""),
         searching_value = Map.get(form, "searching_value", ""),
         args = Map.put(%{}, :token, access_token),
         args = Map.put(args, :filter, %{
            name: searching_value
         }),
         args = Map.put(args, :pagi, %{
            page: 1,
            limit: 100
         }),
         {:ok, playlists} <- GettingListPlaylistUseCase.get(
            Authorization, 
            GettingUser,
            GettingListPlaylistPostgresAdapter,
            args
         ) do
      socket = assign(socket, :playlists, playlists)

      socket = assign(socket, :form_searching, to_form(form))

      {:noreply, socket}
    else 
      {:error, message} -> 
        socket = assign(socket, :success, false)

        socket = assign(socket, :alert, message)

        {:noreply, socket}
    end
  end

  def handle_event("close_alert", _form, socket) do
    socket = assign(socket, :alert, nil)

    socket = assign(socket, :success, nil)

    {:noreply, socket}
  end

  def handle_event("select_device", form, socket) do
    socket = assign(socket, :is_open_drop_down, false)

    socket = assign(socket, :selected_playlist, form["playlist_name"])

    socket = assign(socket, :form, to_form(form))

    socket = assign(socket, :form_searching, to_form(%{
      "searching_value": ""
    }))

    {:noreply, socket}
  end

  def handle_event("address", form, socket) do
    form = Map.put(form, "address", form["value"])

    socket = assign(socket, :form, to_form(form))

    {:noreply, socket}
  end

  def handle_event("latitude", form, socket) do
    form = Map.put(form, "latitude", form["value"])

    socket = assign(socket, :form, to_form(form))

    {:noreply, socket}
  end

  def handle_event("longitude", form, socket) do
    form = Map.put(form, "longitude", form["value"])

    socket = assign(socket, :form, to_form(form))

    {:noreply, socket}
  end

  def handle_event("ssh_port", form, socket) do
    form = Map.put(form, "ssh_port", form["value"])

    socket = assign(socket, :form, to_form(form))

    {:noreply, socket}
  end

  def handle_event("ssh_host", form, socket) do
    form = Map.put(form, "ssh_host", form["value"])

    socket = assign(socket, :form, to_form(form))

    {:noreply, socket}
  end

  def handle_event("ssh_user", form, socket) do
    form = Map.put(form, "ssh_user", form["value"])

    socket = assign(socket, :form, to_form(form))

    {:noreply, socket}
  end

  def handle_event("ssh_password", form, socket) do
    form = Map.put(form, "ssh_password", form["value"])

    socket = assign(socket, :form, to_form(form))

    {:noreply, socket}
  end

  def handle_event("close_drop_down", form, socket) do
    socket = assign(socket, :is_open_drop_down, false)

    socket = assign(socket, :form, to_form(form))

    socket = assign(socket, :form_searching, to_form(%{
      "searching_value": ""
    }))

    {:noreply, socket}
  end

  def handle_event("create_device", form, socket) do
    # args = %{
    #   ssh_port: String.to_integer( Map.get(form, "ssh_port", "") ),
    #   ssh_host: Map.get(form, "ssh_host", ""),
    #   ssh_user: Map.get(form, "ssh_user", ""),
    #   ssh_password: Map.get(form, "ssh_password", ""),
    #   address: Map.get(form, "address", ""),
    #   longitude: String.to_float(Map.get(form, "longitude", "")),
    #   latitude: String.to_float(Map.get(form, "latitude", "")),
    #   playlist_id: Map.get(form, "playlist_id", "")
    # }

    # csrf_token = Map.get(form, "csrf_token", "")

    # with [{_, "", access_token}] <- :ets.lookup(:access_tokens, csrf_token),
    #      args = Map.put(args, :token, access_token),
    #      {:ok, _} <- Creating.create(
    #         Authorization, 
    #         GettingUser, 
    #         GettingPlaylist, 
    #         Inserting, 
    #         args
    #       ) do

    #   Logger.info("Пользователь добавил устройство - #{args}")

    #   {
    #     :noreply,
    #     assign(socket, :state, %{
    #       playlists: [],
    #       geting_playlists: false,
    #       success_creating_device: nil,
    #       error: "",
    #       form: to_form( %{
    #         address: "",
    #         ssh_port: "",
    #         ssh_host: "",
    #         ssh_user: "",
    #         ssh_password: "",
    #         longitude: "",
    #         latitude: "",
    #         playlist_id: "",
    #         csrf_token: Map.get(form, "csrf_token", "")
    #       })
    #     })
    #   }
    # else
    #   [] -> {:noreply, push_redirect(socket, to: "/sign-in")}
    #   {:error, message} ->

    #     Logger.notice(message)

    #     {
    #       :noreply,
    #       assign(socket, :state, %{
    #         playlists: [],
    #         geting_playlists: false,
    #         success_creating_device: false,
    #         error: message,
    #         form: to_form( %{
    #           address: Map.get(form, "address", ""),
    #           ssh_port: Map.get(form, "ssh_port", ""),
    #           ssh_host: Map.get(form, "ssh_host", ""),
    #           ssh_user: Map.get(form, "ssh_user", ""),
    #           ssh_password: Map.get(form, "ssh_password", ""),
    #           longitude: Map.get(form, "longitude", ""),
    #           latitude: Map.get(form, "latitude", ""),
    #           playlist_id: Map.get(form, "playlist_id", ""),
    #           csrf_token: Map.get(form, "csrf_token", "")
    #         })
    #       })
    #     }
    # end
  end
end
