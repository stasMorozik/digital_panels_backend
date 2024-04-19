defmodule NodeApi.User.Controller do

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
          NodeApi.Logger.info("Пользователь авторизован")
          
          json = Jason.encode!(%{
            id: user.id,
            email: user.email,
            name: user.name,
            surname: user.surname,
            created: user.created,
            updated: user.updated
          })

          conn |> 
            Plug.Conn.send_resp(200, json)

        {:error, message} -> NodeApi.Handlers.handle_error(conn, message, 401)

        {:exception, message} -> NodeApi.Handlers.handle_exception(conn, message)
      end
    rescue
      e -> NodeApi.Handlers.handle_exception(conn, e)
    end
  end
end