defmodule PostgresqlAdapters.Playlist.Inserting do
  alias Core.Playlist.Ports.GetterList

  alias Core.Playlist.Entity, as: PlaylistEntity
  alias Core.Content.Entity, as: ContentEntity
  alias Core.File.Entity, as: FileEntity

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

  @behaviour GetterList

  @impl GetterList
  def get(%Filter{
    user_id: user_id,
    name: filter_by_name,
    created: filter_by_created,
    updated: filter_by_updated
  }, %Sort{
    name: sort_by_name,
    created: sort_by_created,
    updated: sort_by_updated
  }, %Pagination{
    page: page,
    limit: limit
  }) do
    case :ets.lookup(:connections, "postgresql") do
      [{"postgresql", "", connection}] ->
        
        offset = cond do
          page == 1 -> 0
          page > 1 -> limit * (page-1)
        end

        query(%Filter{
          user_id: user_id,
          name: filter_by_name,
          created: filter_by_created,
          updated: filter_by_updated
        },%Sort{
          name: sort_by_name,
          created: sort_by_created,
          updated: sort_by_updated
        }, limit, offset)

      [] -> Error.new("Database connection error")
      _ -> Error.new("Database connection error")
    end
  end

  def get(_, _, _) do
    Error.new("Не валидные данные для получения списка плэйлистов")
  end

  defp query(%Filter{
    user_id: user_id,
    name: filter_by_name,
    created: _,
    updated: _
  }, %Sort{
    name: _,
    created: _,
    updated: _
  }, limit, offset, connection) when is_binary(name) do
    query = Postgrex.prepare!(
      connection,
      "",
      "
        SELECT 
          pl.id, pl.name, pl.contents, pl.created, pl.updated
        FROM 
          relations_user_playlist AS rl_u_p
        JOIN 
          playlists AS pl ON pl.id = rl_u_p.playlist_id
        WHERE 
          rl_u_p.user_id = $1 AND
          pl.name = $2
        LIMIT $3 OFFSET $4
      "
    )

    Postgrex.execute(connection, query, [user_id, filter_by_name, limit, offset])
  end

  defp query(%Filter{
    user_id: user_id,
    name: _,
    created: _,
    updated: _
  }, %Sort{
    name: _,
    created: _,
    updated: _
  }, limit, offset, connection) do
    query = Postgrex.prepare!(
      connection,
      "",
      "
        SELECT 
          pl.id, pl.name, pl.contents, pl.created, pl.updated
        FROM 
          relations_user_playlist AS rl_u_p
        JOIN 
          playlists AS pl ON pl.id = rl_u_p.playlist_id
        WHERE 
          rl_u_p.user_id = $1 
        LIMIT $2 OFFSET $3
      "
    )

    Postgrex.execute(connection, query, [user_id, limit, offset]) 
  end
end