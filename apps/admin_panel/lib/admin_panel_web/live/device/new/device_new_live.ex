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
    socket = assign(socket, :current_page, "devices")

    # socket = assign(socket, :state, %{
    #   playlists: [],
    #   geting_playlists: false,
    #   success_creating_device: nil,
    #   error: nil,
    #   form: to_form( %{
    #     address: "",
    #     ssh_port: "",
    #     ssh_host: "",
    #     ssh_user: "",
    #     ssh_password: "",
    #     longitude: "",
    #     latitude: "",
    #     id_playlist: "",
    #     csrf_token: Map.get(session, "_csrf_token", "")
    #   })
    # })

    {:ok, socket}
  end

  def handle_event("get_playlists", form, socket) do
    # with csrf_token = Map.get(form, "csrf_token", ""),
    #      [{_, "", access_token}] <- :ets.lookup(:access_tokens, csrf_token),
    #      args = Map.put(%{}, :token, access_token),
    #      {:ok, playlists} <- GettingListPlaylistUseCase.get(
    #         Authorization, 
    #         GettingUser,
    #         GettingListPlaylistPostgresAdapter,
    #         args
    #      ) do
    #   {
    #     :noreply,
    #     assign(socket, :state, %{
    #       playlists: playlists,
    #       geting_playlists: true,
    #       success_creating_device: nil,
    #       error: nil,
    #       form: to_form( %{
    #         address: Map.get(form, "address", ""),
    #         ssh_port: Map.get(form, "ssh_port", ""),
    #         ssh_host: Map.get(form, "ssh_host", ""),
    #         ssh_user: Map.get(form, "ssh_user", ""),
    #         ssh_password: Map.get(form, "ssh_password", ""),
    #         longitude: Map.get(form, "longitude", ""),
    #         latitude: Map.get(form, "latitude", ""),
    #         id_playlist: Map.get(form, "id_playlist", ""),
    #         csrf_token: Map.get(form, "csrf_token", "")
    #       })
    #     })
    #   }
    # else 
    #   {:error, message} -> 
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

  def handle_event("close_drop_down", form, socket) do
    # {
    #   :noreply,
    #   assign(socket, :state, %{
    #     playlists: [],
    #     geting_playlists: false,
    #     success_creating_device: nil,
    #     error: nil,
    #     form: to_form( %{
    #       address: Map.get(form, "address", ""),
    #       ssh_port: Map.get(form, "ssh_port", ""),
    #       ssh_host: Map.get(form, "ssh_host", ""),
    #       ssh_user: Map.get(form, "ssh_user", ""),
    #       ssh_password: Map.get(form, "ssh_password", ""),
    #       longitude: Map.get(form, "longitude", ""),
    #       latitude: Map.get(form, "latitude", ""),
    #       id_playlist: Map.get(form, "id_playlist", ""),
    #       csrf_token: Map.get(form, "csrf_token", "")
    #     })
    #   })
    # }
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
