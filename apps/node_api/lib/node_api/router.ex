defmodule NodeApi.Router do
  use Plug.Router

  plug :match

  plug Plug.Parsers,
       parsers: [:json, :urlencoded, :multipart],
       pass:  ["application/json", "multipart/form-data"],
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

  put "/api/v1/playlist/" do
    conn 
      |> fetch_cookies()
      |> put_resp_content_type("application/json")
      |> NodeApi.Playlist.Controller.create()
  end

  post "/api/v1/playlist/:id" do
    conn 
      |> fetch_cookies()
      |> put_resp_content_type("application/json")
      |> NodeApi.Playlist.Controller.update(id)
  end

  get "/api/v1/playlist/" do
    conn 
      |> fetch_cookies()
      |> fetch_query_params()
      |> put_resp_content_type("application/json")
      |> NodeApi.Playlist.Controller.list()
  end

  get "/api/v1/playlist/:id" do
    conn 
      |> fetch_cookies()
      |> put_resp_content_type("application/json")
      |> NodeApi.Playlist.Controller.get(id)
  end

  put "/api/v1/file/" do
    conn 
      |> fetch_cookies()
      |> put_resp_content_type("application/json")
      |> NodeApi.File.Controller.create()
  end

  get "/api/v1/file/" do
    conn 
      |> fetch_cookies()
      |> fetch_query_params()
      |> put_resp_content_type("application/json")
      |> NodeApi.File.Controller.list()
  end

  get "/api/v1/file/:id" do
    conn 
      |> fetch_cookies()
      |> put_resp_content_type("application/json")
      |> NodeApi.File.Controller.get(id)
  end

  put "/api/v1/content/" do
    conn 
      |> fetch_cookies()
      |> put_resp_content_type("application/json")
      |> NodeApi.Content.Controller.create()
  end

  post "/api/v1/content/:id" do
    conn 
      |> fetch_cookies()
      |> put_resp_content_type("application/json")
      |> NodeApi.Content.Controller.update(id)
  end

  get "/api/v1/content/" do
    conn 
      |> fetch_cookies()
      |> fetch_query_params()
      |> put_resp_content_type("application/json")
      |> NodeApi.Content.Controller.list()
  end

  get "/api/v1/content/:id" do
    conn 
      |> fetch_cookies()
      |> put_resp_content_type("application/json")
      |> NodeApi.Content.Controller.get(id)
  end

  put "/api/v1/task/" do
    conn 
      |> fetch_cookies()
      |> put_resp_content_type("application/json")
      |> NodeApi.Task.Controller.create()
  end

  post "/api/v1/task/:id" do
    conn 
      |> fetch_cookies()
      |> put_resp_content_type("application/json")
      |> NodeApi.Task.Controller.update(id)
  end

  get "/api/v1/task/" do
    conn 
      |> fetch_cookies()
      |> fetch_query_params()
      |> put_resp_content_type("application/json")
      |> NodeApi.Task.Controller.list()
  end

  get "/api/v1/task/:id" do
    conn 
      |> fetch_cookies()
      |> put_resp_content_type("application/json")
      |> NodeApi.Task.Controller.get(id)
  end

  match _ do
    conn
      |> put_resp_content_type("application/json")
      |> send_resp(404, Jason.encode!(%{message: "Ресурс не найден"}))
  end
end