defmodule Core.User.UseCases.Authentication do
  @moduledoc """
    Юзекейз аутентификации пользователя пользователя
  """

  alias Core.ConfirmationCode.Methods.CheckerHasConfirmation
  alias ConfirmationCode.Ports.Getter, as: GetterCode
  alias User.Ports.Getter, as: GetterUser

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error
  alias Core.Shared.Types.Exception

  @spec auth(
    GetterCode.t(),
    GetterUser.t(),
    map()
  ) :: Success.t() | Error.t() | Exception.t()
  def auth(
    getter_confiramtion_code,
    getter_user,
    args
  ) when is_atom(getter_confiramtion_code)
    and is_atom(getter_user)
    and is_map(args) do
    with {:ok, code_entity} <- getter_confiramtion_code.get(Map.get(args, :email)),
         {:ok, _} <- CheckerHasConfirmation.has(code_entity),
         {:ok, user_entity} <- getter_user.get(Map.get(args, :email)),
         refresh_token <- Core.RefreshToken.Entity.generate_and_sign!(%{id: user_entity.id}),
         access_token <- Core.AccessToken.Entity.generate_and_sign!(%{id: user_entity.id}) do

      Success.new(%{access_token: access_token, refresh_token: refresh_token})

    else
      {:error, error} -> {:error, error}
      {:exception, error} -> {:exception, error}
    end
  end

  def auth(_, _, _) do
    Error.new("Не валидные аргументы для аутентификаци пользователя")
  end
end
