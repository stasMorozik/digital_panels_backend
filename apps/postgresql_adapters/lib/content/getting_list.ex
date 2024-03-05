defmodule PostgresqlAdapters.Content.GettingList do
  
  alias Core.Content.Ports.GetterList

  alias Core.Content.Entity, as: Content
  alias Core.User.Entity, as: User
  
  alias PostgresqlAdapters.Executor

  alias Core.Shared.Types.Pagination
  alias Core.Content.Types.Filter
  alias Core.Content.Types.Sort

  alias PostgresqlAdapters.Content.QueryBuilder

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
             fun <- fn ([id, name, dur, cr, upd]) ->
                %Content{
                  id: UUID.binary_to_string!(id),
                  name: name,
                  duration: dur,
                  created: cr,
                  updated: upd
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
    {:error, "Не валидные данные для получения списка записей о контенте из базы данных"}
  end
end