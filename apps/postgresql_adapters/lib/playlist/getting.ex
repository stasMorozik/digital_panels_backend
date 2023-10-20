defmodule PostgresqlAdapters.Playlist.Getting do
  alias Core.Playlist.Ports.Getter
  alias Core.Playlist.Entity, as: PlaylistEntity

  alias Core.Content.Entity, as: ContentEntity
  alias Core.File.Entity, as: FileEntity

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

  @behaviour Getter

  @impl Getter
  def get(id) when is_binary(id) do
    case :ets.lookup(:connections, "postgresql") do
      [{"postgresql", "", connection}] ->

        with query <- "SELECT * FROM playlists WHERE id = $1",
             {:ok, q} <- Postgrex.prepare(connection, "", query),
             {:ok, _, result} <- Postgrex.execute(connection, q, [UUID.string_to_binary!(id)]),
             true <- result.num_rows > 0,
             [ [id, name, json, created, updated] ] <- result.rows,
             playlist_entity <- mapper([id, name, json, created, updated]) do

          Success.new(playlist_entity)
        else
          false -> Error.new("Плэйлист не найден")
          {:error, _} -> Error.new("Ошибка запроса к базе данных")
        end

      [] -> Error.new("Database connection error")
      _ -> Error.new("Database connection error")
    end
  end

  def get(_) do
    Error.new("Не валидные данные для получения пользователя")
  end

  defp mapper([id, name, json, created, updated]) do
    with {:ok, map} <- Jason.decode(json, [{:keys, :atoms}]),
         fun <- fn content -> 
            %ContentEntity{
              id: content.id,
              display_duration: content.display_duration,
              created: content.created,
              updated: content.updated,
              file: %FileEntity{
                id: content.file.id,
                size: content.file.size, 
                url: content.file.url, 
                path: content.file.path, 
                created: content.file.created,
                updated: content.file.updated
              }
            }
         end,
         contents <- Enum.map(map, fun) do

      %PlaylistEntity{
        id: id,
        name: name,
        contents: contents,
        created: created,
        updated: updated
      }
    else 
      {:error, _} -> Error.new("Ошибка парсинга")
    end
  end
end
