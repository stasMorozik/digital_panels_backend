defmodule NodeApi.Handlers.Error do
  def handle(conn, message) do
    NodeApi.Logger.error(message)

    json = Jason.encode!(%{
      message: message
    })

    status_code = case message do
      "Невалидный токен" -> 401
      "Невалидные аргументы для авторизации пользователя" -> 401
      "Запись о пользователе не найдена в базе данных" -> 401
      _ -> 400 
    end

    conn |> Plug.Conn.send_resp(status_code, json)
  end
end