defmodule PostgresqlAdapters.Task.Inserting do
  
  alias Core.Task.Ports.Transformer
  alias Core.Task.Entity, as: Task
  alias Core.User.Entity, as: User

  @behaviour Transformer

  @query_0 "
    INSERT INTO tasks (
      id,
      name,
      playlist_id,
      group_id,
      type,
      day,
      start_hour,
      end_hour,
      start_minute,
      end_minute,
      start_hm,
      end_hm,
      sum,
      created,
      updated
    ) VALUES(
      $1,
      $2,
      $3,
      $4,
      $5,
      $6,
      $7,
      $8,
      $9,
      $10,
      $11,
      $12,
      $13,
      $14,
      $15
    )
  "

  @query_1 "
    INSERT INTO relations_user_task (
      user_id, 
      task_id
    ) VALUES(
      $1,
      $2
    )
  "

  @impl Transformer
  def transform(%Task{} = task, %User{} = user) do
    case :ets.lookup(:connections, "postgresql") do
      [{"postgresql", "", connection}] ->
        with {:ok, query_0} <- Postgrex.prepare(connection, "", @query_0),
             {:ok, query_1} <- Postgrex.prepare(connection, "", @query_1),
             data_0 <- [
                UUID.string_to_binary!(task.id),
                task.name,
                UUID.string_to_binary!(task.playlist.id),
                UUID.string_to_binary!(task.group.id),
                task.type,
                task.day,
                task.start_hour,
                task.end_hour,
                task.start_minute,
                task.end_minute,
                task.start,
                task.end,
                task.sum,
                task.created,
                task.updated
             ],
             data_1 <- [
                UUID.string_to_binary!(user.id),
                UUID.string_to_binary!(task.id)
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
          {:error, %Postgrex.Error{postgres: %{pg_code: "23505"}}} -> {:error, "Запись о задании в базе данных уже существует"}
          {:error, e} -> {:exception, e}
        end
      [] -> {:exception, "Database connection error"}
      _ -> {:exception, "Database connection error"}
    end
  end

  def transform(_, _) do
    {:error, "Не валидные данные для занесения записи о задании в базу данных"}
  end
end