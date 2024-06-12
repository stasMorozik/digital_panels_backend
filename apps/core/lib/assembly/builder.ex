defmodule Core.Assembly.Builder do
  @moduledoc """
    Билдер сущности
  """

  alias UUID

  alias Core.Shared.Builders.BuilderProperties

  alias Core.Assembly.Validators.Group
  alias Core.Assembly.Validators.Type
  alias Core.Assembly.Validators.Tokens

  @url_web_dav Application.compile_env(:core, :url_web_dav)

  defmodule Validator do
    def valid(_) do
      {:ok, true}
    end
  end

  defmodule AccessToken do
    use Joken.Config

    def token_config, do: default_claims(default_exp: 60 * 60 * 24 * 365)
  end

  defmodule RefreshToken do
    use Joken.Config

    def token_config, do: default_claims(default_exp: 60 * 60 * 24 * 365)
  end

  @spec build(map()) :: Core.Shared.Types.Success.t() | Core.Shared.Types.Error.t()
  def build(%{group: group, type: type}) do
    setter = fn (
      entity, 
      key, 
      value
    ) -> 
      Map.put(entity, key, value) 
    end

    setter_url = fn (
      entity, 
      key, 
      _
    ) -> 
      Map.put(entity, key, "#{@url_web_dav}/#{entity.id}/#{entity.created}.zip") 
    end

    setter_token = fn (
      entity, 
      _, 
      _
    ) -> 
      access_t = AccessToken.generate_and_sign!(%{id: entity.id})
      refresh_t = RefreshToken.generate_and_sign!(%{id: entity.id})

      entity = Map.put(entity, :access_token, access_t)
      entity = Map.put(entity, :refresh_token, refresh_t)

      entity 
    end

    entity()
      |> BuilderProperties.build(Group, setter, :group, group)
      |> BuilderProperties.build(Type, setter, :type, type)
      |> BuilderProperties.build(Validator, setter_url, :url, nil)
      |> BuilderProperties.build(Validator, setter_token, nil, nil)
  end

  def build(_) do
    {:error, "Невалидные данные для построения сборки"}
  end

  # Функция построения базового устройства
  defp entity do
    {:ok, %Core.Assembly.Entity{
      id: UUID.uuid4(),
      status: false, 
      created: Date.utc_today, 
      updated: Date.utc_today
    }}
  end
end