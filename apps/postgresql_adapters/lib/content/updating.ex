defmodule PostgresqlAdapters.Content.Updating do
  
  alias Core.Content.Ports.Transformer
  alias Core.Content.Entity, as: Content
  alias Core.User.Entity, as: User

  @behaviour Transformer

  @query_0 "
    UPDATE 
      contents AS c
    SET
      name = $3,
      duration = $4,
      file_id = $5,
      playlist_id = $6,
      serial_number = $7,
      updated = $8
    FROM 
      relations_user_content AS r
    WHERE 
      r.user_id = $1
    AND
      c.id = $2
  "

  @impl Transformer
  def transform(%Content{} = content, %User{} = user) do
    case :ets.lookup(:connections, "postgresql") do
      [{"postgresql", "", connection}] ->
        with {:ok, query_0} <- Postgrex.prepare(connection, "", @query_0),
             data_0 <- [
                UUID.string_to_binary!(user.id),
                UUID.string_to_binary!(content.id),
                content.name,
                UUID.string_to_binary!(content.file.id),
                UUID.string_to_binary!(content.playlist.id),
                content.serial_number,
                content.updated
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
    {:error, "Не валидные данные для занесения записи о контенте в базу данных"}
  end
end