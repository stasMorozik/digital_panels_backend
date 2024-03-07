defmodule NodeApi.Router do
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
      |> NodeApi.ConfirmationCode.Controller.create()
  end

  # put "/api/v1/user/" do
  #   conn
  #   |> put_resp_content_type("text/plain")
  #   |> send_resp(200, "Привет Мир!\n")
  # end

  post "/api/v1/user/" do
    conn
      |> put_resp_content_type("application/json")
      |> NodeApi.User.Controller.authentication()
  end

  get "/api/v1/user/" do
    conn 
      |> fetch_cookies()
      |> put_resp_content_type("application/json")
      |> NodeApi.User.Controller.authorization()
  end

  match _ do
    conn
      |> put_resp_content_type("application/json")
      |> send_resp(400, Jason.encode!(%{message: "Ресурс не найден"}))
  end
end