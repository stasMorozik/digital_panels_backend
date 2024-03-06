defmodule PostgresqlAdapters.Assembly.GettingList do
  
  alias Core.Assembly.Ports.GetterList

  alias Core.Assembly.Entity, as: Assembly
  alias Core.User.Entity, as: User
  
  alias PostgresqlAdapters.Executor

  alias Core.Shared.Types.Pagination
  alias Core.Assembly.Types.Filter
  alias Core.Assembly.Types.Sort

  alias PostgresqlAdapters.Assembly.QueryBuilder

  @behaviour GetterList

  @impl GetterList
  def get(
    %Pagination{} = pagi, 
    %Filter{} = filter, 
    %Sort{} = sort, 
    %User{} = user
  ) do
    case :ets.lookup(:connections, "postgresql") do
      [{"postgresql", "", connection}] ->
        with {query, data_list} <- QueryBuilder.build(pagi, filter, sort, user),
             {:ok, result} <- Executor.execute(connection, query, data_list),
             true <- result.num_rows > 0,
             fun <- fn ([
                a_id, a_url, a_type, a_st, a_created,
                gr_id, gr_name,
             ]) ->
               %Assembly{
                  id: UUID.binary_to_string!(a_id),
                  url: a_url,
                  type: a_type,
                  status: a_st,
                  created: a_created,
                  group: %Core.Group.Entity{
                    id: UUID.binary_to_string!(gr_id), 
                    name: gr_name
                  }
               }
             end,
             list <- Enum.map(result.rows, fun) do
          {:ok, list}
        else
          false -> {:ok, []}
          {:exception, message} -> {:exception, message}
        end
      [] -> {:exception, "Database connection error"}
      _ -> {:exception, "Database connection error"}
    end
  end

  def get(_, _, _, _) do
    {:error, "Не валидные данные для получения списка записей о сборках из базы данных"}
  end
end