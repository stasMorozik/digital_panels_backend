defmodule AdminPanelWeb.PlaylistNewLive do
  use AdminPanelWeb, :live_view

  alias Core.User.UseCases.Authorization
  alias PostgresqlAdapters.User.GettingById, as: GettingUser

  alias Core.Playlist.UseCases.Creating
  alias HttpAdapters.File.Putting
  alias PostgresqlAdapters.Playlist.Inserting

  def mount(_params, session, socket) do
    csrf_token = Map.get(session, "_csrf_token", "")

    [{_, "", access_token}] = :ets.lookup(:access_tokens, csrf_token)

    socket = assign(socket, :current_page, "playlists")

    socket = assign(socket, :alert, nil)

    socket = assign(socket, :success, nil)

    socket = assign(socket, :access_token, access_token)

    socket = assign(socket, :form, to_form(%{
      name: ""
    }))

    socket = socket
      |> assign(:uploaded_files, [])
      |> allow_upload(:image, accept: ~w(.jpg .jpeg .png .gif .avif), max_entries: 100)

    {:ok, socket}
  end

  def handle_event("close_alert", _form, socket) do
    socket = assign(socket, :alert, nil)

    socket = assign(socket, :success, nil)

    {:noreply, socket}
  end

  def handle_event("change", form, socket) do
    form = Map.drop(form, ["_target"])

    form = to_form(form)
    
    socket = assign(socket, :form, form)

    {:noreply, socket}
  end

  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    socket = cancel_upload(socket, :image, ref)

    {:noreply, socket}
  end

  def handle_event("create_playlist", form, socket) do

    contents = consume_uploaded_entries(socket, :image, fn %{path: path}, entry ->
      dest = "/tmp/#{entry.client_name}"

      content = %{
        display_duration: String.to_integer(form[entry.ref]),
        file: %{
          path: dest
        }
      }

      {:postpone, content}
    end)

    uploaded_files = consume_uploaded_entries(socket, :image, fn %{path: path}, entry ->
      dest = "/tmp/#{entry.client_name}"
      File.cp!(path, dest)
      {:ok, Path.basename(dest)}
    end)


    socket = update(socket, :uploaded_files, &(&1 ++ uploaded_files))

    args = %{
      name: Map.get(form, "name", ""),
      contents: contents,
      web_dav_url: Application.fetch_env!(:core, :web_dav_url),
      token: Map.get(form, "access_token", "")
    }

    case Creating.create(
      Authorization,
      GettingUser,
      Putting,
      Inserting,
      args
    ) do
      {:ok, _} -> 
        socket = assign(socket, :success, true)
        socket = assign(socket, :alert, "Плэйлист успешно добавлен")
        socket = assign(socket, :form, to_form(%{
          name: ""
        }))

        {:noreply, socket}
      {:error, message} -> 
        socket = assign(socket, :form, to_form(%{
          name: ""
        }))
        socket = assign(socket, :success, false)
        socket = assign(socket, :alert, message)

        {:noreply, socket}
    end
  end
end