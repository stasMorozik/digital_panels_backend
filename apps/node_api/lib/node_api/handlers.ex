defmodule NodeApi.Handlers do
  def handle_exception(conn, error) do
    NodeApi.NotifierAdmin.notify(error)

    NodeApi.Logger.exception(error)

    json = Jason.encode!(%{
      message: "Что то пошло не так"
    })
    
    conn |> Plug.Conn.send_resp(500, json)
  end

  def handle_error(conn, message, code) do
    NodeApi.Logger.error(message)

    json = Jason.encode!(%{
      message: message
    })

    conn |> Plug.Conn.send_resp(code, json)
  end
end