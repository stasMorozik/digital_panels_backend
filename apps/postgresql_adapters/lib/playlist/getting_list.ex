defmodule PostgresqlAdapters.Playlist.GettingList do
  alias Core.Playlist.Ports.GetterList

  alias Core.Playlist.Entity, as: PlaylistEntity
  alias Core.Content.Entity, as: ContentEntity
  alias Core.File.Entity, as: FileEntity

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error
  
  alias Core.Playlist.Types.Filter
  alias Core.Playlist.Types.Sort
  alias Core.Shared.Types.Pagination

  @behaviour GetterList

  @impl GetterList
  def get(%Filter{
    user_id: filter_by_user_id,
    name: filter_by_name,
    created_f: filter_by_created_f,
    created_t: filter_by_created_t,
    updated_f: filter_by_updated_f,
    updated_t: filter_by_updated_t
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
        
        filter = %Filter{
          user_id: filter_by_user_id,
          name: filter_by_name,
          created_f: filter_by_created_f,
          created_t: filter_by_created_t,
          updated_f: filter_by_updated_f,
          updated_t: filter_by_updated_t
        }

        sort = %Sort{
          name: sort_by_name,
          created: sort_by_created,
          updated: sort_by_updated
        }

        pagi = %Pagination{
          page: page,
          limit: limit
        }

        # "
        #   SELECT 
        #     pl.id, pl.name, pl.contents, pl.created, pl.updated
        #   FROM 
        #     relations_user_playlist AS rl_u_p
        #   JOIN 
        #     playlists AS pl ON pl.id = rl_u_p.playlist_id
        #   WHERE 
        #     rl_u_p.user_id = $1
        #   #{query_map.filter_by_name}
        #   #{query_map.filter_by_created_f}
        #   #{query_map.filter_by_created_t}
        #   #{query_map.filter_by_updated_f}
        #   #{query_map.filter_by_updated_t}
        #   #{query_map.sort_by_name}
        #   #{query_map.sort_by_created}
        #   #{query_map.sort_by_updated}
        #   LIMIT $2 OFFSET $3
        # "

        Success.new(true)


      [] -> Error.new("Database connection error")
      _ -> Error.new("Database connection error")
    end
  end

  def get(_, _, _) do
    Error.new("Не валидные данные для получения списка плэйлистов")
  end
end