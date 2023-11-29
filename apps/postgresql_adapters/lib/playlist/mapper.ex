defmodule PostgresqlAdapters.Playlist.Mapper do
  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error
  
  alias Core.Playlist.Entity, as: PlaylistEntity
  alias Core.Content.Entity, as: ContentEntity
  alias Core.File.Entity, as: FileEntity

  def to_entity([id, name, json, created, updated]) when is_binary(json) do
    fun = fn (content) -> 
      %ContentEntity {
        id: content.id,
        display_duration: content.display_duration,
        created: content.created,
        updated: content.updated,
        file: %FileEntity {
          id: content.file.id,
          size: content.file.size, 
          url: content.file.url, 
          path: content.file.path, 
          created: content.file.created,
          updated: content.file.updated
        }
      }
    end

    case Jason.decode(json, [{:keys, :atoms}]) do
      {:ok, decodet} -> 
        Success.new(%PlaylistEntity{
          id: UUID.binary_to_string!(id),
          name: name,
          contents: Enum.map(decodet, fun),
          created: created,
          updated: updated
        })
      {:error, _} -> Error.new("Ошибка парсинга")
    end
  end

  def to_entity([id, name, nil, created, updated]) do
    Success.new(%PlaylistEntity{
      id: UUID.binary_to_string!(id),
      name: name,
      contents: [],
      created: created,
      updated: updated
    })
  end
end