defmodule Core.User.UseCases.Authorization do
  @moduledoc """
    Юзекейз авторизации пользователя
  """

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error
  alias Core.Shared.Types.Exception

  alias Core.AccessToken.Entity, as: Token

  @spec auth(
    User.Ports.Getter.t(),
    map()
  ) :: Success.t() | Error.t() | Exception.t()
  def auth(
    getter_user,
    args
  ) when is_atom(getter_user) and is_map(args) do
    with token <- Map.get(args, :token, ""),
         false <- token == nil,
         {result, claims} = Token.verify_and_validate(token),
         :ok <- result,
         string_id <- Map.get(claims, "id"),
         {:ok, user} <- getter_user.get(string_id) do
      {:ok, user}
    else
      true -> {:error, "Невалидный токен"}
      :error -> {:error, "Невалидный токен"}
      {:error, message} -> {:error, message}
      {:exception, message} -> {:exception, message}
    end
  end

  def auth(_, _) do
    {:error, "Невалидные аргументы для авторизации пользователя"}
  end
end
