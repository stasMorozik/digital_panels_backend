defmodule NodeApi.Controllers.User do

  alias Core.User.UseCases.Authorization
  alias PostgresqlAdapters.User.GettingById, as: UserGettingById

  alias NodeApi.Handlers.Success
  alias NodeApi.Handlers.Error
  alias NodeApi.Handlers.Exception

  alias NodeApi.Logger, as: AppLogger

  def authorization(conn) do
    args = %{
      token: Map.get(conn.cookies, "access_token")
    }

    adapter_0 = UserGettingById

    try do
      case Authorization.auth(adapter_0, args) do
        {:ok, user} ->
            AppLogger.info("Пользователь авторизован")

            Success.handle(conn, user)
        {:error, message} -> 
          Error.handle(conn, message)
        {:exception, message} -> 
          Exception.handle(conn, message)
      end
    rescue
      e -> Exception.handle(conn, Map.get(e, :message))
    end
  end
end