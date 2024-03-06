defmodule Api.User.Controller do
  
  def authentication(conn) do
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
end