defmodule Core.User.UseCases.Authentication do
  @moduledoc """
    Юзекейз аутентификации пользователя пользователя
  """

  alias Core.ConfirmationCode.Methods.CheckerHasConfirmation
  alias ConfirmationCode.Ports.Getter, as: GetterCode
  alias User.Ports.Getter, as: GetterUser

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

  @spec auth(
    GetterCode.t(),
    GetterUser.t(),
    map()
  ) :: Success.t() | Error.t()
  def auth(
    getter_confiramtion_code,
    getter_user,
    args
  ) when is_atom(getter_confiramtion_code)
    and is_atom(getter_user)
    and is_map(args) do
    with true <- Kernel.function_exported?(getter_confiramtion_code, :get, 1),
         true <- Kernel.function_exported?(getter_user, :get, 1),
         {:ok, code_entity} <- getter_confiramtion_code.get(Map.get(args, :email)),
         {:ok, _} <- CheckerHasConfirmation.has(code_entity),
         {:ok, user_entity} <- getter_user.get(Map.get(args, :email)) do

      refresh_token = Core.RefreshToken.Entity.generate_and_sign!(%{id: user_entity.id})
      access_token = Core.AccessToken.Entity.generate_and_sign!(%{id: user_entity.id})

      Success.new(%{access_token: access_token, refresh_token: refresh_token})

    else
      false -> Error.new("Не валидные аргументы для аутентификаци пользователя")
      {:error, error} -> {:error, error}
    end
  end

  def auth(_, _, _) do
    Error.new("Не валидные аргументы для аутентификаци пользователя")
  end
end
