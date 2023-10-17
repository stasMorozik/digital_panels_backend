defmodule Core.RefreshToken.UseCases.Refreshing do
  @moduledoc """
    Юзекейз обновления токенов
  """

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

  @spec refresh(
    binary()
  ) :: Success.t() | Error.t()
  def refresh(token) when is_binary(token) do
    {result, maybe_claims} = Core.RefreshToken.Entity.verify_and_validate(token)

    case result do
      :error -> Error.new("Не валидный токен")
      :ok ->

        refresh_token = Core.RefreshToken.Entity.generate_and_sign!(%{id: Map.get(maybe_claims, "id", "")})
        access_token = Core.AccessToken.Entity.generate_and_sign!(%{id: Map.get(maybe_claims, "id", "")})

        Success.new(%{access_token: access_token, refresh_token: refresh_token})
    end
  end

  def refresh(_) do
    Error.new("Не валидные аргументы для обновления токена")
  end
end
