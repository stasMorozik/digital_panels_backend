defmodule PostgresqlAdapters.Playlist.Updating do
  
  alias Core.Playlist.Ports.Transformer
  alias Core.Playlist.Entity, as: Playlist
  alias Core.User.Entity, as: User

  @behaviour Transformer

  @query_0 "
    UPDATE 
      playlists AS p 
    SET
      name = $3,
      sum = $4,
      updated = $5
    FROM 
      relations_user_playlist AS r
    WHERE 
      r.user_id = $1
    AND
      p.id = $2
  "

  @impl Transformer
  def transform(%Playlist{} = playlist, %User{} = user) do
    case :ets.lookup(:connections, "postgresql") do
      [{"postgresql", "", connection}] ->
        with {:ok, query_0} <- Postgrex.prepare(connection, "", @query_0),
             data_0 <- [
                UUID.string_to_binary!(user.id),
                UUID.string_to_binary!(playlist.id),
                playlist.name,
                playlist.sum,
                playlist.updated
             ],
             fun <- fn(conn) ->
                r_0 = Postgrex.execute(conn, query_0, data_0)

                case r_0 do
                  {:ok, _, _} -> {:ok, true}
                  {:error, e} -> DBConnection.rollback(conn, e)
                end
             end,
             {:ok, _} <- Postgrex.transaction(connection, fun) do
          {:ok, true}
        else
          {:error, e} -> {:exception, e}
        end
      [] -> {:exception, "Database connection error"}
      _ -> {:exception, "Database connection error"}
    end
  end

  def transform(_, _) do
    {:error, "Не валидные данные для занесения записи о плэйлисте в базу данных"}
  end
end