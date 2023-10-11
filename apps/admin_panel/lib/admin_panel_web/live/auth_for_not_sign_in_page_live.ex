defmodule AdminPanelWeb.AuthForNotSignInPageLive do
  use AdminPanelWeb, :live_view

  alias AdminPanelWeb.Services.Authorization

  def on_mount(:default, _parrams, session, socket) do
    csrf_token = Map.get(session, "_csrf_token", "")

    case Authorization.auth(csrf_token) do
      {:ok, user} ->
        socket = assign(socket, :user, user)

        {:cont, socket}
      {:error, _} -> {:halt, redirect(socket, to: "/sign-in")}
    end
  end
end
