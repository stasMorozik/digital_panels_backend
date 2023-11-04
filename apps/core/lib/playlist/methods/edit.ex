defmodule Core.Playlist.Methods.Edit do
  @moduledoc """
    Изменяет поля сущности
  """

  alias Core.Playlist.Entity

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

  @spec edit(Entity.t(), map()) :: Success.t() | Error.t()
  def edit(%Entity{
    id: id,
    name: name,
    contents: contents,
    created: created,
    updated: updated
  }, %{
    name: new_name,
    contents: new_contents,
    web_dav_url: web_dav_url
  }) when is_binary(new_name) do
    
    entity = %Entity{
      id: id,
      name: name,
      contents: contents,
      created: created,
      updated: updated
    }

    map = %{
      name: new_name,
      contents: new_contents,
      web_dav_url: web_dav_url
    }
  
  end

  def edit(_, _) do
    Error.new("Не валидные данные для редактирования плэйлиста")
  end

  defp updated(entity) do
    Success.new(Map.put(entity, :updated, Date.utc_today))
  end

  defp is_nil({:ok, entity}, map, key) do
    case Map.get(map, key) do
      nil -> {:nil, entity}
      _ -> { :ok, entity }
    end
  end

  defp is_nil({ :error, entity }, _, _) do
    { :error, entity }
  end
end