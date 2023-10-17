defmodule FakeAdapters.Playlist.GetterList do
  alias Core.Playlist.Ports.GetterList
  alias Core.Playlist.Entity

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

  alias Core.Playlist.Types.Filter
  alias Core.Playlist.Types.Sort
  alias Core.Shared.Types.Pagination

  @behaviour GetterList

  @impl GetterList
  def get(%Filter{
    name: name,
    created: _,
    updated: _
  }, %Sort{
    name: _,
    created: _,
    updated: _
  }, %Pagination{
    page: _,
    limit: _
  }) do
    case :mnesia.transaction(fn -> :mnesia.index_read(:playlists, name, :name) end) do
      {:atomic, list_playlists} ->
        if length(list_playlists) > 0 do

          [playlist | _] = list_playlists

          {:playlists, id, _, name, created, updated} = playlist

          Success.new([%Entity{
            id: id,
            name: name,
            contents: [],
            created: created,
            updated: updated
          }])

        else
          Error.new("Плэйлисты не найден")
        end
      {:aborted, _} ->  Error.new("Плэйлисты не найден")
    end
  end

  def get(_, _, _) do
    Error.new("Не валидный id")
  end
end
