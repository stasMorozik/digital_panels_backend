defmodule NodeApi.Controllers.User do

  alias Core.User.UseCases.Authorization
  alias PostgresqlAdapters.User.GettingById, as: UserGettingById

  def authorization(conn) do
    args = %{
      token: Map.get(conn.cookies, "access_token")
    }

    adapter_0 = UserGettingById

    try do
      case Authorization.auth(adapter_0, args) do
        {:ok, user} ->
          message = "Пользователь авторизован"
          payload = %{
            id: user.id,
            email: user.email,
            name: user.name,
            surname: user.surname,
            created: user.created,
            updated: user.updated
          }

          NodeApi.Handlers.Success.handle(conn, payload, message)
        {:error, message} -> 
          NodeApi.Handlers.Error.handle(conn, message)
        {:exception, message} -> 
          NodeApi.Handlers.Exception.handle(conn, message)
      end
    rescue
      e -> NodeApi.Handlers.Exception.handle(conn, Map.get(e.message))
    end
  end
end