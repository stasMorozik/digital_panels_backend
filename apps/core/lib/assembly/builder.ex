defmodule Core.Assembly.Builder do
  @moduledoc """
    Билдер сущности
  """

  alias UUID

  @spec build(map()) :: Core.Shared.Types.Success.t() | Core.Shared.Types.Error.t()
  def build(%{group: group, type: type}) do
    entity()
      |> Core.Assembly.Builders.Group.build(group)
      |> Core.Assembly.Builders.Type.build(type)
      |> Core.Assembly.Builders.Url.build()
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