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

  get "/api/v1/token/" do
    conn 
      |> fetch_cookies()
      |> put_resp_content_type("application/json")
      |> NodeApi.RefreshToken.Controller.refresh()
  end

  put "/api/v1/group/" do
    conn 
      |> fetch_cookies()
      |> put_resp_content_type("application/json")
      |> NodeApi.Group.Controller.create()
  end

  post "/api/v1/group/:id" do
    conn 
      |> fetch_cookies()
      |> put_resp_content_type("application/json")
      |> NodeApi.Group.Controller.update(id)
  end

  get "/api/v1/group/" do
    conn 
      |> fetch_cookies()
      |> fetch_query_params()
      |> put_resp_content_type("application/json")
      |> NodeApi.Group.Controller.list()
  end

  get "/api/v1/group/:id" do
    conn 
      |> fetch_cookies()
      |> put_resp_content_type("application/json")
      |> NodeApi.Group.Controller.get(id)
  end

  put "/api/v1/device/" do
    conn 
      |> fetch_cookies()
      |> put_resp_content_type("application/json")
      |> NodeApi.Device.Controller.create()
  end

  post "/api/v1/device/:id" do
    conn 
      |> fetch_cookies()
      |> put_resp_content_type("application/json")
      |> NodeApi.Device.Controller.update(id)
  end

  get "/api/v1/device/" do
    conn 
      |> fetch_cookies()
      |> fetch_query_params()
      |> put_resp_content_type("application/json")
      |> NodeApi.Device.Controller.list()
  end

  get "/api/v1/device/:id" do
    conn 
      |> fetch_cookies()
      |> put_resp_content_type("application/json")
      |> NodeApi.Device.Controller.get(id)
  end

  match _ do
    conn
      |> put_resp_content_type("application/json")
      |> send_resp(400, Jason.encode!(%{message: "Ресурс не найден"}))
  end
end