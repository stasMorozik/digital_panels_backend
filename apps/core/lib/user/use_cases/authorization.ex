defmodule Core.User.UseCases.Authorization do
  @moduledoc """
    Юзекейз авторизации пользователя
  """

  alias User.Ports.Getter

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error
  alias Core.Shared.Types.Exception

  @spec auth(
    Getter.t(),
    map()
  ) :: Success.t() | Error.t() | Exception.t()
  def auth(
    getter_user,
    args
  ) when is_atom(getter_user)
    and is_map(args) do
      with token <- Map.get(args, :token, ""),
           false <- token == nil,
           {result, claims} = Core.AccessToken.Entity.verify_and_validate(token),
           :ok <- result do

        getter_user.get(UUID.string_to_binary!(Map.get(claims, "id")))

      else
        true -> Error.new("Не валидный токен")
        :error -> Error.new("Не валидный токен")
      end
  end

  def auth(_, _) do
    Error.new("Не валидные аргументы для авторизации пользователя")
  end
end
