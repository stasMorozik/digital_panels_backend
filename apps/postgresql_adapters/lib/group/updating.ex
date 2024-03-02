defmodule PostgresqlAdapters.Group.Updating do
  
  alias Core.Group.Ports.Transformer
  alias Core.Group.Entity, as: Group
  alias Core.User.Entity, as: User

  @behaviour Transformer

  @query_0 "
    UPDATE 
      groups 
    SET
      name = $2,
      sum = $3,
      updated = $4
    WHERE 
      id = $1
  "

  @impl Transformer
  def transform(%Group{} = group, %User{} = _user) do
    case :ets.lookup(:connections, "postgresql") do
      [{"postgresql", "", connection}] ->
        with {:ok, query_0} <- Postgrex.prepare(connection, "", @query_0),
             data_0 <- [
                UUID.string_to_binary!(group.id),
                group.name,
                group.sum,
                group.updated
             ],
             fun <- fn(conn) ->
                r_0 = Postgrex.execute(conn, query_0, data_0)

                case {r_0} do
                  {{:ok, _, _}} -> {:ok, true}
                  {{:error, e}} -> DBConnection.rollback(conn, e)
                end
             end,
             {:ok, _} <- Postgrex.transaction(connection, fun) do
          {:ok, true}
        else
          {:error, %Postgrex.Error{postgres: %{pg_code: "23505"}}} -> {:error, "Запись о группе в базе данных уже существует"}
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