defmodule Api.Router do
  use Plug.Router

  @from Application.compile_env(:core, :email_address)

  plug :match

  plug Plug.Parsers,
       parsers: [:json],
       pass:  ["application/json"],
       json_decoder: Jason

  plug :dispatch

  

  put "/api/v1/confirmation-code/" do
    args = %{needle: Map.get(conn.body_params, "needle")}
    
    conn = conn
      |> put_resp_content_type("application/json")

    try do
      case Core.ConfirmationCode.UseCases.Creating.create(
        PostgresqlAdapters.ConfirmationCode.Inserting,
        Api.NotifierUser,
        args
      ) do
        {:ok, true} -> 
          Api.Logger.info("Успешное создание кода подтверждения")
          conn |> send_resp(200, Jason.encode!(true))

        {:error, message} -> 
          Api.Logger.info(message)
          conn |> send_resp(400, Jason.encode!(%{message: message}))

        {:exception, message} -> 
          Api.Logger.exception(message)
          Api.NotifierDev.notify(%{
            to: "@Stanm858",
            from: @from,
            subject: "Exception",
            message: message
          })
          conn |> send_resp(500, Jason.encode!(%{message: "Что то пошло не так"}))
      end
    rescue
      e -> 
        Api.Logger.exception(e)
        Api.NotifierDev.notify(%{
          to: "@Stanm858",
          from: @from,
          subject: "Exception",
          message: e.message
        })
        conn |> send_resp(500, Jason.encode!(%{message: "Что то пошло не так"}))
    end
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