defmodule Core.User.UseCases.Authentication do
  @moduledoc """
    Юзекейз аутентификации пользователя пользователя
  """

  alias Core.ConfirmationCode.Methods.Confirmatory
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
         {:ok, _} <- Confirmatory.confirm(code_entity, Map.get(args, :code)),
         {:ok, user_entity} <- getter_user.get(Map.get(args, :email)),
         r_token <- Core.RefreshToken.Entity.generate_and_sign!(%{id: user_entity.id}),
         a_token <- Core.AccessToken.Entity.generate_and_sign!(%{id: user_entity.id}) do

      {:ok, %{access_token: a_token, refresh_token: r_token}}

    else
      {:error, error} -> {:error, error}
      {:exception, error} -> {:exception, error}
    end
  end

  def auth(_, _, _) do
    {:error, "Невалидные аргументы для аутентификаци пользователя"}
  end
end
