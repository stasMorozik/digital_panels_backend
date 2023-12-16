defmodule Core.RefreshToken.UseCases.Refreshing do
  @moduledoc """
    Юзекейз обновления токенов
  """

  alias Core.RefreshToken.Entity, as: RefreshToken
  alias Core.AccessToken.Entity, as: AccessToken

  @spec refresh(any()) :: Core.Shared.Types.Success.t() | Core.Shared.Types.Error.t()
  def refresh(token) when is_binary(token) do
    {result, maybe_claims} = RefreshToken.verify_and_validate(token)

    case result do
      :error -> {:error , "Не валидный токен"}
      :ok ->

        r_token = RefreshToken.generate_and_sign!(%{
          id: Map.get(maybe_claims, "id", "")
        })
        
        a_token = AccessToken.generate_and_sign!(%{
          id: Map.get(maybe_claims, "id", "")
        })

        {:ok, %{
          access_token: r_token, 
          refresh_token: a_token
        }}
    end
  end

  def refresh(_) do
    {:error, "Не валидные аргументы для обновления токена"}
  end
end
