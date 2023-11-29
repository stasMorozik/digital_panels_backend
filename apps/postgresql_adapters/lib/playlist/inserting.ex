defmodule PostgresqlAdapters.Playlist.Inserting do
  alias Core.Playlist.Ports.Transformer
  
  alias Core.Playlist.Entity, as: PlaylistEntity
  alias Core.User.Entity, as: UserEntity

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error
  alias Core.Shared.Types.Exception

  @behaviour Transformer

  @impl Transformer
  def transform(%PlaylistEntity{} = playlist, %UserEntity{} = user) do
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
                UUID.string_to_binary!(playlist.id),
                playlist.name,
                Jason.encode!(playlist.contents),
                playlist.created,
                playlist.updated
             ],
             d_1 <- [
                UUID.string_to_binary!(user.user_id),
                UUID.string_to_binary!(playlist.id),
             ],
             fun <- fn(conn) ->
                r_0 = Postgrex.execute(conn, q_0, d_0)
                r_1 = Postgrex.execute(conn, q_1, d_1)

                case {r_0, r_1} do
                  {{:ok, _, _}, {:ok, _, _}} -> {:ok, true}
                  {{:error, e}, {:ok, _, _}} -> DBConnection.rollback(conn, e)
                  {{:ok, _, _}, {:error, e}} -> DBConnection.rollback(conn, e)
                  {{:error, e}, {:error, _}} -> DBConnection.rollback(conn, e)
                end
             end,
             {:ok, _} <- Postgrex.transaction(connection, fun) do
          Success.new(true)
        else
          {:error, %Postgrex.Error{postgres: %{pg_code: "23505"}}} -> Error.new("Плэйлист уже существует")
          {:error, e} -> Exception.new(e.message)
        end

      [] -> Exception.new("Database connection error")
      _ -> Exception.new("Database connection error")
    end
  end

  def transform(_, _) do
    Error.new("Не возможно занести запись в хранилище данных")
  end
end
