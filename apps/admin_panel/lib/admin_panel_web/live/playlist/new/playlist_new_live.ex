defmodule AdminPanelWeb.PlaylistNewLive do
  use AdminPanelWeb, :live_view

  alias Core.User.UseCases.Authorization
  alias PostgresqlAdapters.User.GettingById, as: GettingUser

  def mount(_params, session, socket) do
    csrf_token = Map.get(session, "_csrf_token", "")

    [{_, "", access_token}] = :ets.lookup(:access_tokens, csrf_token)

    socket = assign(socket, :current_page, "playlists")

    socket = assign(socket, :error, nil)

    socket = assign(socket, :access_token, access_token)

    socket = assign(socket, :form, to_form(%{
      name: ""
    }))

    socket = socket
      |> assign(:uploaded_files, [])
      |> allow_upload(:image, accept: ~w(.jpg .jpeg .png .gif .avif), max_entries: 100)

    {:ok, socket}
  end

  def handle_event("change", form, socket) do
    form = Map.drop(form, ["_target"])
    IO.inspect(form)

    form = to_form(form)

    IO.inspect(form)
    
    socket = assign(socket, :form, form)

    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    socket = cancel_upload(socket, :image, ref)

    {:noreply, socket}
  end

  def handle_event("create_playlist", form, socket) do
    IO.inspect(form)
    {:noreply, socket}
  end
end