defmodule Api.Router do
  use Plug.Router

  @from Application.compile_env(:core, :email_address)
  @developer_telegram_login Application.compile_env(:api, :developer_telegram_login)

  plug :match

  plug Plug.Parsers,
       parsers: [:json],
       pass:  ["application/json"],
       json_decoder: Jason

  plug :dispatch

  put "/api/v1/confirmation-code/" do
    conn = conn
      |> put_resp_content_type("application/json")

    args = %{needle: Map.get(conn.body_params, "needle")}

    try do
      case Core.ConfirmationCode.UseCases.Creating.create(
        PostgresqlAdapters.ConfirmationCode.Inserting,
        Api.NotifierUser,
        args
      ) do
        {:ok, true} -> 
          Api.Logger.info("Успешное создание кода подтверждения")

          conn |> send_resp(200, Jason.encode!(true))

        {:error, message} -> handle_error(conn, message, 400)

        {:exception, message} -> handle_exception(conn, message)
      end
    rescue
      e -> handle_exception(conn, e)
    end
  end

  # put "/api/v1/user/" do
  #   conn
  #   |> put_resp_content_type("text/plain")
  #   |> send_resp(200, "Привет Мир!\n")
  # end

  post "/api/v1/user/" do
    conn = conn
      |> put_resp_content_type("application/json")

    args = %{
      email: Map.get(conn.body_params, "email"),
      code: Map.get(conn.body_params, "code"),
    }

    try do
      case Core.User.UseCases.Authentication.auth(
        PostgresqlAdapters.ConfirmationCode.Getting,
        PostgresqlAdapters.User.GettingByEmail,
        args
      ) do
        {:ok, tokens} -> 
          Api.Logger.info("Успешная аутентификация пользователя")

          conn 
            |> put_resp_cookie("access_token", tokens.access_token)
            |> put_resp_cookie("refresh_token", tokens.refresh_token)  
            |> send_resp(200, Jason.encode!(true))
          
        {:error, message} -> handle_error(conn, message, 400)

        {:exception, message} -> handle_exception(conn, message)
      end
    rescue
      e -> handle_exception(conn, e)
    end
  end

  get "/api/v1/user/" do
    conn = conn
      |> fetch_cookies()
      |> put_resp_content_type("application/json")

    args = %{
      token: Map.get(conn.cookies, "access_token")
    }

    try do
      case Core.User.UseCases.Authorization.auth(
        PostgresqlAdapters.User.GettingById,
        args
      ) do
        {:ok, user} ->
          Api.Logger.info("Успешная авторизация пользователя")

          conn |> send_resp(200, Jason.encode!(%{
            id: user.id,
            email: user.email,
            name: user.name,
            surname: user.surname,
            created: user.created,
            updated: user.updated
          }))

        {:error, message} -> handle_error(conn, message, 401)

        {:exception, message} -> handle_exception(conn, message)
      end
    rescue
      e -> handle_exception(conn, e)
    end
  end

  match _ do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(400, Jason.encode!(%{message: "Ресурс не найден"}))
  end

  defp handle_exception(conn, error) do
    Api.Logger.exception(error)

    Api.NotifierDev.notify(%{
      to: @developer_telegram_login,
      from: @from,
      subject: "Exception",
      message: error
    })

    conn |> send_resp(500, Jason.encode!(%{message: "Что то пошло не так"}))
  end

  defp handle_error(conn, message, code) do
    Api.Logger.info(message)

    conn |> send_resp(code, Jason.encode!(%{message: message}))
  end
end