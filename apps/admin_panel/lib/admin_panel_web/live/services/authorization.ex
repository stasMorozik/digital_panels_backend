defmodule AdminPanelWeb.Services.Authorization do
  require Logger

  alias Core.User.UseCases.Authorization
  alias PostgresqlAdapters.User.GettingById

  alias Core.RefreshToken.UseCases.Refreshing

  def auth(csrf_token) do
    with [{_, "", access_token}] <- :ets.lookup(:access_tokens, csrf_token),
         {:ok, user} <- Authorization.auth(GettingById, %{token: access_token}) do

      {:ok, user}
    else
      [] -> {:error, "Токен не найден"}
      {:error, message} ->

        with [{_, "", refresh_token}] <- :ets.lookup(:refresh_tokens, csrf_token),
             {:ok, tokens} <- Refreshing.refresh(refresh_token),
             {:ok, user} <- Authorization.auth(GettingById, %{token: tokens.access_token}) do

          :ets.insert(:access_tokens, {csrf_token, "", tokens.access_token})
          :ets.insert(:refresh_tokens, {csrf_token, "", tokens.refresh_token})

          {:ok, user}
        else
          [] -> {:error, "Токен не найден"}
          {:error, message} -> {:error, message}
          {:exception, message} -> {:exception, message}
        end
        
      {:exception, message} -> {:exception, message}
    end
  end
end
