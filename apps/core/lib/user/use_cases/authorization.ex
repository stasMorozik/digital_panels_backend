defmodule Core.User.UseCases.Authorization do
  @moduledoc """
    Юзекейз авторизации пользователя
  """

  alias User.Ports.Getter

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

  @spec auth(
    Getter.t(),
    map()
  ) :: Success.t() | Error.t()
  def auth(
    getter_user,
    args
  ) when is_atom(getter_user)
    and is_map(args) do
      with true <- Kernel.function_exported?(getter_user, :get, 1),
           token <- Map.get(args, :token, ""),
           false <- token == nil do

        {result, maybe_claims} = Core.AccessToken.Entity.verify_and_validate(token)

        case result do
          :error -> Error.new("Не валидный токен")
          :ok -> getter_user.get(Map.get(maybe_claims, "id"))
        end

      else
        false -> Error.new("Не валидные аргументы для авторизации пользователя")
        true -> Error.new("Не валидный токен")
      end
  end

  def auth(_, _) do
    Error.new("Не валидные аргументы для авторизации пользователя")
  end
end
