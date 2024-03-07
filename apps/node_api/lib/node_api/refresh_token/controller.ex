defmodule NodeApi.RefreshToken.Controller do

  alias Core.RefreshToken.UseCases.Refreshing

  def refresh(conn) do
    try do
      case Refreshing.refresh(Map.get(conn.cookies, "refresh_token")) do
        {:ok, tokens} ->
          NodeApi.Logger.info("Токен обновлен")
          
          conn 
            |> Plug.Conn.put_resp_cookie("access_token", tokens.access_token)
            |> Plug.Conn.put_resp_cookie("refresh_token", tokens.refresh_token)  
            |> Plug.Conn.send_resp(200, Jason.encode!(true))

        {:error, message} -> NodeApi.Handlers.handle_error(conn, message, 401)

        {:exception, message} -> NodeApi.Handlers.handle_exception(conn, message)
      end
    rescue
      e -> NodeApi.Handlers.handle_exception(conn, e)
    end
  end
end