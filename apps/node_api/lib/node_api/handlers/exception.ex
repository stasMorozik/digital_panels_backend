defmodule NodeApi.Handlers.Exception do
  def handle(conn, message) do
    NodeApi.Notifiers.Admin.notify(message)

    NodeApi.Logger.exception(message)

    json = Jason.encode!(%{
      message: "Что то пошло не так"
    })
    
    conn |> Plug.Conn.send_resp(500, json)
  end
end