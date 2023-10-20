defmodule PostgresqlAdapters.Playlist.Inserting do
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
    contents: contents,
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
    case :ets.lookup(:connections, "postgresql") do
      [{"postgresql", "", connection}] ->

        query_0 = "
          INSERT INTO playlists (
            id,
            name,
            contents,
            created,
            updated
          ) VALUES(
            $1, $2, $3, $4, $5
          )
        "

        query_1 = "
          INSERT INTO relations_user_playlist (
            user_id,
            playlist_id
          ) VALUES(
            $1, $2
          )
        "

        with {:ok, q_0} <- Postgrex.prepare(connection, "", query_0),
             {:ok, q_1} <- Postgrex.prepare(connection,"", query_1),
             d_0 <- [
                UUID.string_to_binary!(id),
                name,
                Jason.encode!(contents),
                created,
                updated
             ],
             d_1 <- [
                UUID.string_to_binary!(user_id),
                UUID.string_to_binary!(id),
             ],
             fun <- fn(conn) ->
                Postgrex.execute(conn, q_0, d_0)
                Postgrex.execute(conn, q_1, d_1)
             end,
             {:ok, _} <- Postgrex.transaction(connection, fun) do
          Success.new(true)
        else 
          {:error, _} -> Error.new("Ошибка запроса к базе данных")
        end

      [] -> Error.new("Database connection error")
      _ -> Error.new("Database connection error")
    end
  end

  def transform(_, _) do
    Error.new("Не возможно занести запись в хранилище данных")
  end
end
