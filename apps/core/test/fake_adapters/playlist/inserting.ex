defmodule FakeAdapters.Playlist.Inserting do
  alias Core.Playlist.Ports.Transformer
  alias Core.Playlist.Entity, as: PlaylistEntity
  alias Core.User.Entity, as: UserEntity

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

  @behaviour Transformer

  @impl Transformer
  def transform(%PlaylistEntity{
    id: id,
    name: name,
    contents: _,
    created: created,
    updated: updated
  }, %UserEntity{
    id: user_id,
    email: _,
    name: _,
    surname: _,
    created: _,
    updated: _
  }) do
    case :mnesia.transaction(
      fn -> :mnesia.write({
        :playlists,
          id,
          user_id,
          name,
          created,
          updated
      }) end
    ) do
      {:atomic, :ok} -> Success.new(true)
      {:aborted, _} -> Error.new("Плэйлист уже существует")
    end
  end

  def transform(_, _) do
    Error.new("Не возможно занести запись в хранилище данных")
  end
end
