defmodule NodeApi.Handlers.Success do
  def handle(conn, payload, message) do
    NodeApi.Logger.info(message)

    json = Jason.encode!(payload)

    conn |> Plug.Conn.send_resp(200, json)
  end
end