defmodule Api.Router do
  use Plug.Router

  plug :match

  plug Plug.Parsers,
       parsers: [:json],
       pass:  ["application/json"],
       json_decoder: Jason

  plug :dispatch

  put "/api/v1/confirmation-code/" do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Jason.encode!(%{message: "test"}))
  end

  # post "/api/v1/user/" do
  #   conn
  #   |> put_resp_content_type("text/plain")
  #   |> send_resp(200, "Привет Мир!\n")
  # end

  # put "/api/v1/user/" do
  #   conn
  #   |> put_resp_content_type("text/plain")
  #   |> send_resp(200, "Привет Мир!\n")
  # end

  # get "/api/v1/user/" do
  #   conn
  #   |> put_resp_content_type("text/plain")
  #   |> send_resp(200, "Привет Мир!\n")
  # end

  match _ do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(400, Jason.encode!(%{message: "Ресурс не найден"}))
  end
end