defmodule NodeWebsocketDevice.Router do
  use Plug.Router

  plug :match

  plug :dispatch

  match _ do
    conn
      |> put_resp_content_type("application/json")
      |> send_resp(404, Jason.encode!(%{message: "Ресурс не найден"}))
  end
end