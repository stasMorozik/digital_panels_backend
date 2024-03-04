defmodule PostgresqlAdapters.Content.Inserting do
  
  alias Core.Content.Ports.Transformer
  alias Core.Content.Entity, as: Content
  alias Core.User.Entity, as: User

  @behaviour Transformer

  @query_0 "
    INSERT INTO contents (
      id,
      name,
      duration,
      file_id,
      playlist_id,
      serial_number,
      created,
      updated,
    ) VALUES(
      $1,
      $2,
      $3,
      $4,
      $5,
      $6,
      $7,
      $8
    )
  "

  @query_1 "
    INSERT INTO relations_user_content (
      user_id, 
      content_id
    ) VALUES(
      $1,
      $2
    )
  "

  @impl Transformer
  def transform(%Content{} = content, %User{} = user) do
    case :ets.lookup(:connections, "postgresql") do
      [{"postgresql", "", connection}] ->
        with {:ok, query_0} <- Postgrex.prepare(connection, "", @query_0),
             {:ok, query_1} <- Postgrex.prepare(connection, "", @query_1),
             data_0 <- [
                UUID.string_to_binary!(content.id),
                content.name,
                content.duration,
                UUID.string_to_binary!(content.file.id),
                UUID.string_to_binary!(content.playlist.id),
                content.serial_number,
                content.created,
                content.updated
             ],
             data_1 <- [
                UUID.string_to_binary!(user.id),
                UUID.string_to_binary!(content.id)
             ],
             fun <- fn(conn) ->
                r_0 = Postgrex.execute(conn, query_0, data_0)
                r_1 = Postgrex.execute(conn, query_1, data_1)

                case {r_0, r_1} do
                  {{:ok, _, _}, {:ok, _, _}} -> {:ok, true}
                  {{:error, e}, {:ok, _, _}} -> DBConnection.rollback(conn, e)
                  {{:ok, _, _}, {:error, e}} -> DBConnection.rollback(conn, e)
                  {{:error, e}, {:error, _}} -> DBConnection.rollback(conn, e)
                end
             end,
             {:ok, _} <- Postgrex.transaction(connection, fun) do
          {:ok, true}
        else
          {:error, %Postgrex.Error{postgres: %{pg_code: "23505"}}} -> {:error, "Запись о контенте в базе данных уже существует"}
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