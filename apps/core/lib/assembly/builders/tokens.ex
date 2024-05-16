defmodule Core.Assembly.Builders.Tokens do
  
  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

  defmodule Core.Assembly.Builders.Tokens.AccessToken do
    use Joken.Config

    def token_config, do: default_claims(default_exp: 60 * 60 * 24 * 365)
  end

  defmodule Core.Assembly.Builders.Tokens.RefreshToken do
    use Joken.Config

    def token_config, do: default_claims(default_exp: 60 * 60 * 24 * 365)
  end

  @spec build(Success.t() | Error.t()) :: Success.t() | Error.t()
  def build({:ok, entity}) do
    access_t = Core.Assembly.Builders.Tokens.AccessToken.generate_and_sign!(%{id: entity.id})
    refresh_t = Core.Assembly.Builders.Tokens.RefreshToken.generate_and_sign!(%{id: entity.id})

    entity = Map.put(entity, :access_token, access_t)
    entity = Map.put(entity, :refresh_token, refresh_t)

    {:ok, entity}
  end

  def build({:error, message}) do
    {:error, message}
  end
end