defmodule AdminPanelWeb.AuthForSignInPageLive do
  use AdminPanelWeb, :live_view

  alias AdminPanelWeb.Services.Authorization

  def on_mount(:default, _parrams, session, socket) do
    csrf_token = Map.get(session, "_csrf_token", "")

    case Authorization.auth(csrf_token) do
      {:ok, user} ->
        socket = assign(socket, :user, user)

        {:halt, redirect(socket, to: "/devices")}
      {:error, message} -> {:cont, socket}
    end
  end
end
