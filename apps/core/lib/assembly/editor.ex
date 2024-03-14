defmodule Core.Assembly.Editor do
  @moduledoc """
    Билдер сущности
  """

  alias Core.Assembly.Entity

  @spec edit(Entity.t()) :: Core.Shared.Types.Success.t() | Core.Shared.Types.Error.t()
  def edit(%Entity{} = entity) do
    entity(entity)
  end

  def build(_) do
    {:error, "Невалидные данные для редактирования сборки"}
  end

  # Функция построения базового устройства
  defp entity(entity) do
    {:ok, %Entity{
      id: entity.id, 
      group: entity.group,
      url: entity.url,
      type: entity.type,
      status: true,
      access_token: entity.access_token,
      refresh_token: entity.refresh_token,
      created: entity.created, 
      updated: entity.updated
    }}
  end
end