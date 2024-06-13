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
      |> NodeApi.Controllers.ConfirmationCode.create()
  end

  put "/api/v1/token/" do
    conn
      |> put_resp_content_type("application/json")
      |> NodeApi.Controllers.Token.create()
  end

  post "/api/v1/token/" do
    conn 
      |> fetch_cookies()
      |> put_resp_content_type("application/json")
      |> NodeApi.Controllers.Token.refresh()
  end

  get "/api/v1/user/" do
    conn 
      |> fetch_cookies()
      |> put_resp_content_type("application/json")
      |> NodeApi.Controllers.User.authorization()
  end

  put "/api/v1/group/" do
    conn 
      |> fetch_cookies()
      |> put_resp_content_type("application/json")
      |> NodeApi.Controllers.Group.create()
  end

  post "/api/v1/group/:id" do
    conn 
      |> fetch_cookies()
      |> put_resp_content_type("application/json")
      |> NodeApi.Controllers.Group.update(id)
  end

  get "/api/v1/group/" do
    conn 
      |> fetch_cookies()
      |> fetch_query_params()
      |> put_resp_content_type("application/json")
      |> NodeApi.Controllers.Group.list()
  end

  get "/api/v1/group/:id" do
    conn 
      |> fetch_cookies()
      |> put_resp_content_type("application/json")
      |> NodeApi.Controllers.Group.get(id)
  end

  put "/api/v1/device/" do
    conn 
      |> fetch_cookies()
      |> put_resp_content_type("application/json")
      |> NodeApi.Controllers.Device.create()
  end

  post "/api/v1/device/:id" do
    conn 
      |> fetch_cookies()
      |> put_resp_content_type("application/json")
      |> NodeApi.Controllers.Device.update(id)
  end

  get "/api/v1/device/" do
    conn 
      |> fetch_cookies()
      |> fetch_query_params()
      |> put_resp_content_type("application/json")
      |> NodeApi.Controllers.Device.list()
  end

  get "/api/v1/device/:id" do
    conn 
      |> fetch_cookies()
      |> put_resp_content_type("application/json")
      |> NodeApi.Controllers.Device.get(id)
  end

  put "/api/v1/playlist/" do
    conn 
      |> fetch_cookies()
      |> put_resp_content_type("application/json")
      |> NodeApi.Controllers.Playlist.create()
  end

  post "/api/v1/playlist/:id" do
    conn 
      |> fetch_cookies()
      |> put_resp_content_type("application/json")
      |> NodeApi.Controllers.Playlist.update(id)
  end

  get "/api/v1/playlist/" do
    conn 
      |> fetch_cookies()
      |> fetch_query_params()
      |> put_resp_content_type("application/json")
      |> NodeApi.Controllers.Playlist.list()
  end

  get "/api/v1/playlist/:id" do
    conn 
      |> fetch_cookies()
      |> put_resp_content_type("application/json")
      |> NodeApi.Controllers.Playlist.get(id)
  end

  put "/api/v1/file/" do
    conn 
      |> fetch_cookies()
      |> put_resp_content_type("application/json")
      |> NodeApi.Controllers.File.create()
  end

  get "/api/v1/file/" do
    conn 
      |> fetch_cookies()
      |> fetch_query_params()
      |> put_resp_content_type("application/json")
      |> NodeApi.Controllers.File.list()
  end

  get "/api/v1/file/:id" do
    conn 
      |> fetch_cookies()
      |> put_resp_content_type("application/json")
      |> NodeApi.Controllers.File.get(id)
  end

  put "/api/v1/content/" do
    conn 
      |> fetch_cookies()
      |> put_resp_content_type("application/json")
      |> NodeApi.Controllers.Content.create()
  end

  post "/api/v1/content/:id" do
    conn 
      |> fetch_cookies()
      |> put_resp_content_type("application/json")
      |> NodeApi.Controllers.Content.update(id)
  end

  get "/api/v1/content/" do
    conn 
      |> fetch_cookies()
      |> fetch_query_params()
      |> put_resp_content_type("application/json")
      |> NodeApi.Controllers.Content.list()
  end

  get "/api/v1/content/:id" do
    conn 
      |> fetch_cookies()
      |> put_resp_content_type("application/json")
      |> NodeApi.Controllers.Content.get(id)
  end

  put "/api/v1/task/" do
    conn 
      |> fetch_cookies()
      |> put_resp_content_type("application/json")
      |> NodeApi.Controllers.Task.create()
  end

  post "/api/v1/task/:id" do
    conn 
      |> fetch_cookies()
      |> put_resp_content_type("application/json")
      |> NodeApi.Controllers.Task.update(id)
  end

  get "/api/v1/task/" do
    conn 
      |> fetch_cookies()
      |> fetch_query_params()
      |> put_resp_content_type("application/json")
      |> NodeApi.Controllers.Task.list()
  end

  get "/api/v1/task/:id" do
    conn 
      |> fetch_cookies()
      |> put_resp_content_type("application/json")
      |> NodeApi.Controllers.Task.get(id)
  end

  put "/api/v1/assembly/" do
    conn 
      |> fetch_cookies()
      |> put_resp_content_type("application/json")
      |> NodeApi.Controllers.Assembly.create()
  end

  post "/api/v1/assembly/:id" do
    conn 
      |> fetch_cookies()
      |> put_resp_content_type("application/json")
      |> NodeApi.Controllers.Assembly.update(id)
  end

  get "/api/v1/assembly/" do
    conn 
      |> fetch_cookies()
      |> fetch_query_params()
      |> put_resp_content_type("application/json")
      |> NodeApi.Controllers.Assembly.list()
  end

  get "/api/v1/assembly/:id" do
    conn 
      |> fetch_cookies()
      |> put_resp_content_type("application/json")
      |> NodeApi.Controllers.Assembly.get(id)
  end

  match _ do
    conn
      |> put_resp_content_type("application/json")
      |> send_resp(404, Jason.encode!(%{message: "Ресурс не найден"}))
  end
end