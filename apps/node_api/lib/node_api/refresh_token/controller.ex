defmodule NodeApi.RefreshToken.Controller do

  alias Core.RefreshToken.UseCases.Refreshing

  @name_node Application.compile_env(:node_api, :name_node)

  def refresh(conn) do
    try do
      case Refreshing.refresh(Map.get(conn.cookies, "refresh_token")) do
        {:ok, tokens} ->
          ModLogger.Logger.info(%{
            message: "Токен обновлен", 
            node: @name_node
          })
          
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