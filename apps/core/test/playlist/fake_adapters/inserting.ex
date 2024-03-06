defmodule Playlist.FakeAdapters.Inserting do
  alias Core.Playlist.Ports.Transformer

  @behaviour Transformer

  alias Core.Playlist.Entity, as: PlaylistEntity
  alias Core.User.Entity, as: UserEntity

  @impl Transformer
  def transform(%PlaylistEntity{} = playlist, %UserEntity{} = _) do
    case :mnesia.transaction(
      fn -> :mnesia.write({
        :playlists, 
        playlist.id, 
        playlist.name,
        playlist.sum, 
        playlist.contents,
        playlist.created,
        playlist.updated
      }) end
    ) do
      {:atomic, :ok} -> {:ok, true}
      {:aborted, _} -> {:error, "Плэйлист уже существует"}
    end
  end
end