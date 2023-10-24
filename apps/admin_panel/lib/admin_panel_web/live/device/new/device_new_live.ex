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

    socket = assign(socket, :error, nil)

    socket = assign(socket, :access_token, access_token)

    socket = assign(socket, :form, to_form(%{
      address: "",
      ssh_port: "",
      ssh_host: "",
      ssh_user: "",
      ssh_password: "",
      longitude: "",
      latitude: "",
      id_playlist: ""
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

      {:noreply, socket}
    else 
      {:error, message} -> 
        socket = assign(socket, :error, message)

        {:noreply, socket}
    end
  end

  def handle_event("address", form, socket) do
    socket = assign(socket, :form, to_form(%{
      address: Map.get(form, "value"),
      ssh_port: Map.get(form, "ssh_port"),
      ssh_host: Map.get(form, "ssh_host"),
      ssh_user: Map.get(form, "ssh_user"),
      ssh_password: Map.get(form, "ssh_password"),
      longitude: Map.get(form, "longitude"),
      latitude: Map.get(form, "latitude"),
      id_playlist: Map.get(form, "id_playlist")
    }))

    {:noreply, socket}
  end

  def handle_event("latitude", form, socket) do
    socket = assign(socket, :form, to_form(%{
      address: Map.get(form, "address"),
      ssh_port: Map.get(form, "ssh_port"),
      ssh_host: Map.get(form, "ssh_host"),
      ssh_user: Map.get(form, "ssh_user"),
      ssh_password: Map.get(form, "ssh_password"),
      longitude: Map.get(form, "longitude"),
      latitude: Map.get(form, "value"),
      id_playlist: Map.get(form, "id_playlist")
    }))

    {:noreply, socket}
  end

  def handle_event("longitude", form, socket) do
    socket = assign(socket, :form, to_form(%{
      address: Map.get(form, "address"),
      ssh_port: Map.get(form, "ssh_port"),
      ssh_host: Map.get(form, "ssh_host"),
      ssh_user: Map.get(form, "ssh_user"),
      ssh_password: Map.get(form, "ssh_password"),
      longitude: Map.get(form, "value"),
      latitude: Map.get(form, "latitude"),
      id_playlist: Map.get(form, "id_playlist")
    }))

    {:noreply, socket}
  end

  def handle_event("ssh_port", form, socket) do
    socket = assign(socket, :form, to_form(%{
      address: Map.get(form, "address"),
      ssh_port: Map.get(form, "value"),
      ssh_host: Map.get(form, "ssh_host"),
      ssh_user: Map.get(form, "ssh_user"),
      ssh_password: Map.get(form, "ssh_password"),
      longitude: Map.get(form, "longitude"),
      latitude: Map.get(form, "latitude"),
      id_playlist: Map.get(form, "id_playlist")
    }))

    {:noreply, socket}
  end

  def handle_event("ssh_host", form, socket) do
    socket = assign(socket, :form, to_form(%{
      address: Map.get(form, "address"),
      ssh_port: Map.get(form, "ssh_port"),
      ssh_host: Map.get(form, "value"),
      ssh_user: Map.get(form, "ssh_user"),
      ssh_password: Map.get(form, "ssh_password"),
      longitude: Map.get(form, "longitude"),
      latitude: Map.get(form, "latitude"),
      id_playlist: Map.get(form, "id_playlist")
    }))

    {:noreply, socket}
  end

  def handle_event("ssh_user", form, socket) do
    socket = assign(socket, :form, to_form(%{
      address: Map.get(form, "address"),
      ssh_port: Map.get(form, "ssh_port"),
      ssh_host: Map.get(form, "ssh_host"),
      ssh_user: Map.get(form, "value"),
      ssh_password: Map.get(form, "ssh_password"),
      longitude: Map.get(form, "longitude"),
      latitude: Map.get(form, "latitude"),
      id_playlist: Map.get(form, "id_playlist")
    }))

    {:noreply, socket}
  end

  def handle_event("ssh_password", form, socket) do
    socket = assign(socket, :form, to_form(%{
      address: Map.get(form, "address"),
      ssh_port: Map.get(form, "ssh_port"),
      ssh_host: Map.get(form, "ssh_host"),
      ssh_user: Map.get(form, "ssh_user"),
      ssh_password: Map.get(form, "value"),
      longitude: Map.get(form, "longitude"),
      latitude: Map.get(form, "latitude"),
      id_playlist: Map.get(form, "id_playlist")
    }))

    {:noreply, socket}
  end

  def handle_event("close_drop_down", form, socket) do
    socket = assign(socket, :is_open_drop_down, false)

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
    #   id_playlist: Map.get(form, "id_playlist", "")
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
    #         id_playlist: "",
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
    #           id_playlist: Map.get(form, "id_playlist", ""),
    #           csrf_token: Map.get(form, "csrf_token", "")
    #         })
    #       })
    #     }
    # end
  end
end
