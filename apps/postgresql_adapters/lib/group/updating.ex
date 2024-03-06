defmodule PostgresqlAdapters.Group.Updating do
  
  alias Core.Group.Ports.Transformer
  alias Core.Group.Entity, as: Group
  alias Core.User.Entity, as: User

  @behaviour Transformer

  @query_0 "
    UPDATE 
      groups AS g 
    SET
      name = $3,
      sum = $4,
      updated = $5
    FROM 
      relations_user_group AS r
    WHERE 
      r.user_id = $1
    AND
      g.id = $2
  "

  @impl Transformer
  def transform(%Group{} = group, %User{} = user) do
    case :ets.lookup(:connections, "postgresql") do
      [{"postgresql", "", connection}] ->
        with {:ok, query_0} <- Postgrex.prepare(connection, "", @query_0),
             data_0 <- [
                UUID.string_to_binary!(user.id),
                UUID.string_to_binary!(group.id),
                group.name,
                group.sum,
                group.updated
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
    {:error, "Не валидные данные для занесения записи о группе в базу данных"}
  end
end