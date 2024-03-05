defmodule PostgresqlAdapters.Task.GettingList do
  
  alias Core.Task.Ports.GetterList

  alias Core.Task.Entity, as: Task
  alias Core.User.Entity, as: User
  
  alias PostgresqlAdapters.Executor

  alias Core.Shared.Types.Pagination
  alias Core.Task.Types.Filter
  alias Core.Task.Types.Sort

  alias PostgresqlAdapters.Task.QueryBuilder

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
              id, nm, tp, day, start_h, end_h, start_m, end_m, start_hm, end_hm, sum, cr,
              gr_id, gr_nm, gr_cr, gr_upd,
             ]) ->
               %Task{
                  id: UUID.binary_to_string!(id),
                  name: nm,
                  type: tp,
                  day: day,
                  start_hour: start_h,
                  end_hour: end_h,
                  start_minute: start_m,
                  end_minute: end_m,
                  start: start_hm,
                  end: end_hm,
                  sum: sum,
                  created: cr,
                  group: %Core.Group.Entity{
                    id: UUID.binary_to_string!(gr_id),
                    name: gr_nm,
                    created: gr_cr, 
                    updated: gr_upd
                  },
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
    {:error, "Не валидные данные для получения списка записей о заданиях из базы данных"}
  end
end