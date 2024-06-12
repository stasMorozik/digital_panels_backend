defmodule NodeApi.Controllers.Token do

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
          message = "Пользователь аутентифицирован"
          payload = true

          conn = conn 
            |> Plug.Conn.put_resp_cookie("access_token", tokens.access_token)
            |> Plug.Conn.put_resp_cookie("refresh_token", tokens.refresh_token)
          
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
  
  def refresh(conn) do
    try do
      case Refreshing.refresh(Map.get(conn.cookies, "refresh_token")) do
        {:ok, tokens} ->
          message = "Токен обновлен"
          payload = true

          conn = conn 
            |> Plug.Conn.put_resp_cookie("access_token", tokens.access_token)
            |> Plug.Conn.put_resp_cookie("refresh_token", tokens.refresh_token)  
          
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