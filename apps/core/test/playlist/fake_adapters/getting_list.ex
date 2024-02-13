defmodule Playlist.FakeAdapters.GettingList do
  alias Core.Playlist.Ports.GetterList

  @behaviour GetterList

  alias Core.Playlist.Entity, as: PlaylistEntity
  alias Core.User.Entity, as: UserEntity

  alias Core.Shared.Types.Pagination
  alias Core.Playlist.Types.Filter
  alias Core.Playlist.Types.Sort

  @impl GetterList
  def get(%Pagination{} = _ , %Filter{} = filter, %Sort{} = _, %UserEntity{} = _) do
    case :mnesia.transaction (fn -> :mnesia.index_read(:playlists, filter.name, :name) end) do
      {:atomic, list_playlists} -> 
        case length(list_playlists) > 0 do
          false -> {:ok, []}
          true -> 
            [playlist | _] = list_playlists

            {:playlists, id, name, sum, contents, created, updated} = playlist

            {:ok, [%PlaylistEntity{
              id: id,
              name: name,
              sum: sum,
              contents: contents,
              created: created,
              updated: updated
            }]}
        end
      {:aborted, _} -> {:ok, []}
    end
  end
end