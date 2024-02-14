defmodule Playlist.FakeAdapters.Getting do
  alias Core.Playlist.Ports.Getter

  @behaviour Getter

  alias Core.Playlist.Entity, as: PlaylistEntity
  alias Core.User.Entity, as: UserEntity

  @impl Getter
  def get(id, %UserEntity{} = _) do
    case :mnesia.transaction (fn -> :mnesia.read({:playlists, UUID.binary_to_string!(id)}) end) do
      {:atomic, list_playlists} -> 
        case length(list_playlists) > 0 do
          false -> {:error, "Плэйлист не найден"}
          true -> 
            [playlist | _] = list_playlists

            {:playlists, id, name, sum, contents, created, updated} = playlist

            {:ok, %PlaylistEntity{
              id: id,
              name: name,
              sum: sum,
              contents: contents,
              created: created,
              updated: updated
            }}
        end
      {:aborted, t} -> 
        IO.inspect(t)
        {:error, "Плэйлист не найден"}
    end
  end
end