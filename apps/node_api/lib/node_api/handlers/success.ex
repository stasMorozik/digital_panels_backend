defmodule NodeApi.Handlers.Success do
  def handle(conn, payload, _) do
    json = Jason.encode!(payload)

    conn |> Plug.Conn.send_resp(200, json)
  end

  def handle(conn, payload) do
    json = Jason.encode!(payload)

    conn |> Plug.Conn.send_resp(200, json)
  end
end