defmodule AdminPanelWeb.AuthForSignInPageLive do
  use AdminPanelWeb, :live_view

  require Logger

  alias Core.User.UseCases.Authorization
  alias PostgresqlAdapters.User.GettingById

  def on_mount(:default, _parrams, session, socket) do
    csrf_token = Map.get(session, "_csrf_token", "")

    with [{_, "", jwt_token}] <- :ets.lookup(:access_tokens, csrf_token),
         {:ok, user} <- Authorization.auth(GettingById, %{token: jwt_token}) do

      Logger.info("Success authorization by #{jwt_token}")

      socket = assign(socket, :user, user)

      {:halt, redirect(socket, to: "/devices")}
    else
      [] -> {:cont, socket}
      {:error, message} ->

        Logger.notice("#{message}")

        {:cont, socket}
    end
  end
end
