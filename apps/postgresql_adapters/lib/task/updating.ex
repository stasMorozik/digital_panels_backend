defmodule PostgresqlAdapters.Task.Updating do
  
  alias Core.Task.Ports.Transformer
  alias Core.Task.Entity, as: Task
  alias Core.User.Entity, as: User

  @behaviour Transformer

  @query_0 "
    UPDATE 
      tasks AS t
    SET
      name = $3,
      playlist_id = $4,
      group_id = $5,
      type = $6,
      day = $7,
      start_hour = $8,
      end_hour = $9,
      start_minute = $10,
      end_minute = $11,
      start_hm = $12,
      end_hm = $13,
      sum = $14,
      updated = $15
    FROM 
      relations_user_task AS r
    WHERE 
      r.user_id = $1
    AND
      t.id = $2
  "

  @impl Transformer
  def transform(%Task{} = task, %User{} = user) do
    case :ets.lookup(:connections, "postgresql") do
      [{"postgresql", "", connection}] ->
        with {:ok, query_0} <- Postgrex.prepare(connection, "", @query_0),
             data_0 <- [
                UUID.string_to_binary!(user.id),
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
                task.updated
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
    {:error, "Не валидные данные для занесения записи о задании в базу данных"}
  end
end