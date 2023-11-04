defmodule FakeAdapters.Playlist.Getter do
  alias Core.Playlist.Ports.Getter
  alias Core.Playlist.Entity

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

  @behaviour Getter

  @impl Getter
  def get(id) when is_binary(id) do
    case :mnesia.transaction(fn -> :mnesia.index_read(
      :playlists, UUID.binary_to_string!(id), :id
    ) end) do
      {:atomic, list_playlists} ->
        if length(list_playlists) > 0 do

          [playlist | _] = list_playlists

          {:playlists, created, _, name, id, updated} = playlist

          Success.new(%Entity{
            id: id,
            name: name,
            contents: [],
            created: created,
            updated: updated
          })

        else
          Error.new("Плэйлист не найден")
        end
      {:aborted, _} ->  Error.new("Плэйлист не найден")
    end
  end

  def get(_) do
    Error.new("Не валидный id")
  end
end
