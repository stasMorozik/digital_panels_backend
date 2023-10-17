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
    user_id: filter_by_user_id,
    name: filter_by_user_name,
    created_f: filter_by_user_created_f,
    created_t: filter_by_user_created_t,
    updated_f: filter_by_user_updated_f,
    updated_t: filter_by_user_updated_t
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
          user_id: filter_by_user_id,
          name: filter_by_user_name,
          created_f: filter_by_user_created_f,
          created_t: filter_by_user_created_t,
          updated_f: filter_by_user_updated_f,
          updated_t: filter_by_user_updated_t
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
    user_id: filter_by_user_id,
    name: filter_by_user_name,
    created_f: filter_by_user_created_f,
    created_t: filter_by_user_created_t,
    updated_f: filter_by_user_updated_f,
    updated_t: filter_by_user_updated_t
  }, %Sort{
    name: sort_by_name,
    created: sort_by_created,
    updated: sort_by_updated
  }, limit, offset, connection) do

    filter_map = %{
      count: 3,
      name: "",
      created_f: "",
      created_t: "",
      updated_f: "",
      updated_t: ""
    }

    Map.put(filter_map, :name, )

    # where = cond do
    #   filter_by_user_name != nil -> 
    #     where_count = where_count + 1
        
    #     "AND name LIKE $#{where_count}"
    #   filter_by_user_name == nil -> ""
    # end

    # where = cond do
    #   filter_by_user_created_f != nil && where_count ==  -> "AND name LIKE $4"
    #   created == nil -> ""
    # end

    # text_query = "
    #   SELECT 
    #     pl.id, pl.name, pl.contents, pl.created, pl.updated
    #   FROM 
    #     relations_user_playlist AS rl_u_p
    #   JOIN 
    #     playlists AS pl ON pl.id = rl_u_p.playlist_id
    #   WHERE 
    #     rl_u_p.user_id = $1

    #   LIMIT $2 OFFSET $3
    # "

    # query = Postgrex.prepare!(
    #   connection,
    #   "",
    #   "
    #     SELECT 
    #       pl.id, pl.name, pl.contents, pl.created, pl.updated
    #     FROM 
    #       relations_user_playlist AS rl_u_p
    #     JOIN 
    #       playlists AS pl ON pl.id = rl_u_p.playlist_id
    #     WHERE 
    #       rl_u_p.user_id = $1
    #     LIMIT $2 OFFSET $3
    #   "
    # )

    # Postgrex.execute(connection, query, [user_id, limit, offset]) 
  end
end