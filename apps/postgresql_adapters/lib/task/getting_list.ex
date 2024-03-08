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
              task_id,
              task_nm,
              task_tp,
              task_day,
              task_start_h,
              task_end_h,
              task_start_m,
              task_end_m,
              task_cr,
              task_shm,
              task_ehm,
              gr_id,
              gr_nm
             ]) ->
               %Task{
                  id: UUID.binary_to_string!(task_id),
                  name: task_nm,
                  type: task_tp,
                  day: task_day,
                  start_hour: task_start_h,
                  end_hour: task_end_h,
                  start_minute: task_start_m,
                  end_minute: task_end_m,
                  created: task_cr,
                  start: task_shm,
                  end: task_ehm,
                  group: %Core.Group.Entity{
                    id: UUID.binary_to_string!(gr_id),
                    name: gr_nm
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