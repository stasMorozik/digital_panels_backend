defmodule PostgresqlAdapters.Assembly.Updating do
  
  alias Core.Assembly.Ports.Transformer
  alias Core.Assembly.Entity, as: Assembly
  alias Core.User.Entity, as: User

  @behaviour Transformer

  @query_0 "
    UPDATE 
      assemblies AS a 
    SET
      status = $3,
      updated = $4
    FROM 
      relations_user_assembly AS r
    WHERE 
      r.user_id = $1
    AND
      a.id = $2
  "

  @impl Transformer
  def transform(%Assembly{} = assembly, %User{} = user) do
    case :ets.lookup(:connections, "postgresql") do
      [{"postgresql", "", connection}] ->
        with {:ok, query_0} <- Postgrex.prepare(connection, "", @query_0),
             data_0 <- [
                UUID.string_to_binary!(user.id),
                UUID.string_to_binary!(assembly.id),
                assembly.status,
                assembly.updated
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
    {:error, "Не валидные данные для занесения записи о сборке в базу данных"}
  end
end