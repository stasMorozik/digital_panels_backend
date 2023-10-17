defmodule AdminPanelWeb.Services.Authorization do
  require Logger

  alias Core.User.UseCases.Authorization
  alias PostgresqlAdapters.User.GettingById

  alias Core.RefreshToken.UseCases.Refreshing

  def auth(csrf_token) do
    with [{_, "", access_token}] <- :ets.lookup(:access_tokens, csrf_token),
         {:ok, user} <- Authorization.auth(GettingById, %{token: access_token}) do

      Logger.info("Пользователь авторизован с токеном - #{access_token}")

      {:ok, user}
    else
      [] -> token_was_not_found_in_ets("Токен доступа не найден в ets")
      {:error, message} ->
        Logger.notice("#{message}")

        with [{_, "", refresh_token}] <- :ets.lookup(:refresh_tokens, csrf_token),
             {:ok, tokens} <- Refreshing.refresh(refresh_token),
             {:ok, user} <- Authorization.auth(GettingById, %{token: tokens.access_token}) do

          Logger.info("Пользователь обновил токены - #{refresh_token}")
          Logger.info("Пользователь авторизован с токеном - #{tokens.access_token}")

          :ets.insert(:access_tokens, {csrf_token, "", tokens.access_token})
          :ets.insert(:refresh_tokens, {csrf_token, "", tokens.refresh_token})

          {:ok, user}
        else
          [] -> token_was_not_found_in_ets("Токен обновления не найден в ets")
          {:error, message} -> core_error(message)
        end

    end
  end

  defp token_was_not_found_in_ets(log_message) do
    Logger.notice(log_message)

    {:error, "Токен не найден"}
  end

  defp core_error(log_message) do
    Logger.notice("#{log_message}")

    {:error, log_message}
  end
end
