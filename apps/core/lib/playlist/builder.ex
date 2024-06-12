defmodule Core.Playlist.Builder do
  @moduledoc """
    Билдер сущности
  """

  alias Core.Shared.Builders.BuilderProperties

  alias Core.Playlist.Validators.Name

  @spec build(map()) :: Core.Shared.Types.Success.t() | Core.Shared.Types.Error.t()
  def build(%{name: name}) do
    setter = fn (
      entity, 
      key, 
      value
    ) -> 
      Map.put(entity, key, value) 
    end

    entity() 
      |> BuilderProperties.build(Name, setter, :name, name)
  end

  def build(_) do
    {:error, "Невалидные данные для построения плэйлиста"}
  end

  # Функция построения базового плэйлиста
  defp entity do
    {:ok, %Core.Playlist.Entity{
      id: UUID.uuid4(),
      sum: 0, 
      created: Date.utc_today, 
      updated: Date.utc_today
    }}
  end
end