defmodule NodeApi.Token.Controller do

  alias Core.RefreshToken.UseCases.Refreshing
  alias Core.User.UseCases.Authentication

  alias PostgresqlAdapters.ConfirmationCode.Getting, as: ConfirmationCodeGetting
  alias PostgresqlAdapters.User.GettingByEmail, as: UserGettingByEmail

  def create(conn) do
    args = %{
      email: Map.get(conn.body_params, "email"),
      code: Map.get(conn.body_params, "code"),
    }

    adapter_0 = ConfirmationCodeGetting
    adapter_1 = UserGettingByEmail

    try do
      case Authentication.auth(adapter_0, adapter_1, args) do
        {:ok, tokens} -> 
          NodeApi.Logger.info("Пользователь аутентифицирован")

          json = Jason.encode!(true)

          conn 
            |> Plug.Conn.put_resp_cookie("access_token", tokens.access_token)
            |> Plug.Conn.put_resp_cookie("refresh_token", tokens.refresh_token)  
            |> Plug.Conn.send_resp(200, json)
          
        {:error, message} -> NodeApi.Handlers.handle_error(conn, message, 400)
        
        {:exception, message} -> NodeApi.Handlers.handle_exception(conn, message)
      end
    rescue
      e -> NodeApi.Handlers.handle_exception(conn, e)
    end
  end
  
  def refresh(conn) do
    try do
      case Refreshing.refresh(Map.get(conn.cookies, "refresh_token")) do
        {:ok, tokens} ->
          NodeApi.Logger.info("Токен обновлен")
          
          json = Jason.encode!(true)

          conn 
            |> Plug.Conn.put_resp_cookie("access_token", tokens.access_token)
            |> Plug.Conn.put_resp_cookie("refresh_token", tokens.refresh_token)  
            |> Plug.Conn.send_resp(200, json)

        {:error, message} -> NodeApi.Handlers.handle_error(conn, message, 401)

        {:exception, message} -> NodeApi.Handlers.handle_exception(conn, message)
      end
    rescue
      e -> NodeApi.Handlers.handle_exception(conn, e)
    end
  end
end