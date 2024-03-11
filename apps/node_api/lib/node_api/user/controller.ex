defmodule NodeApi.User.Controller do

  alias Core.User.UseCases.Authentication
  alias Core.User.UseCases.Authorization

  alias PostgresqlAdapters.ConfirmationCode.Getting, as: ConfirmationCodeGetting
  alias PostgresqlAdapters.User.GettingByEmail, as: UserGettingByEmail
  alias PostgresqlAdapters.User.GettingById, as: UserGettingById

  @name_node Application.compile_env(:node_api, :name_node)

  def authentication(conn) do
    args = %{
      email: Map.get(conn.body_params, "email"),
      code: Map.get(conn.body_params, "code"),
    }

    try do
      case Authentication.auth(ConfirmationCodeGetting, UserGettingByEmail, args) do
        {:ok, tokens} -> 
          ModLogger.Logger.info(%{
            message: "Пользователь аутентифицирован", 
            node: @name_node
          })

          conn 
            |> Plug.Conn.put_resp_cookie("access_token", tokens.access_token)
            |> Plug.Conn.put_resp_cookie("refresh_token", tokens.refresh_token)  
            |> Plug.Conn.send_resp(200, Jason.encode!(true))
          
        {:error, message} -> NodeApi.Handlers.handle_error(conn, message, 400)
        
        {:exception, message} -> NodeApi.Handlers.handle_exception(conn, message)
      end
    rescue
      e -> NodeApi.Handlers.handle_exception(conn, e)
    end
  end

  def authorization(conn) do
    args = %{
      token: Map.get(conn.cookies, "access_token")
    }

    try do
      case Authorization.auth(UserGettingById, args) do
        {:ok, user} ->
          ModLogger.Logger.info(%{
            message: "Пользователь авторизован",
            node: @name_node
          })
          
          conn |> 
            Plug.Conn.send_resp(200, Jason.encode!(%{
              id: user.id,
              email: user.email,
              name: user.name,
              surname: user.surname,
              created: user.created,
              updated: user.updated
            }))

        {:error, message} -> NodeApi.Handlers.handle_error(conn, message, 401)

        {:exception, message} -> NodeApi.Handlers.handle_exception(conn, message)
      end
    rescue
      e -> NodeApi.Handlers.handle_exception(conn, e)
    end
  end
end