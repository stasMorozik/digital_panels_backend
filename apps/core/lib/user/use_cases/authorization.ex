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
         binary_id <- UUID.string_to_binary!(string_id) do
      getter_user.get(binary_id)
    else
      true -> {:error, "Невалидный токен"}
      :error -> {:error, "Невалидный токен"}
    end
  end

  def auth(_, _) do
    {:error, "Невалидные аргументы для авторизации пользователя"}
  end
end
