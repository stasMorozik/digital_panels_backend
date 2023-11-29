defmodule PostgresqlAdapters.Device.GettingList do
  alias Core.Device.Ports.GetterList

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error
  alias Core.Shared.Types.Exception
  
  alias Core.Device.Types.Filter
  alias Core.Device.Types.Sort
  alias Core.Shared.Types.Pagination

  alias PostgresqlAdapters.Executor
  alias PostgresqlAdapters.Device.QueryBuilder
  alias PostgresqlAdapters.Device.Mapper

  @behaviour GetterList

  @impl GetterList
  def get(%Filter{} = filter, %Sort{} = sort, %Pagination{} = pagi) do
    case :ets.lookup(:connections, "postgresql") do
      [{"postgresql", "", connection}] ->
        with {query, data_list} <- QueryBuilder.build(filter, sort, pagi),
             {:ok, result} <- Executor.execute(query, data_list),
             true <- result.num_rows > 0,
             rows <- data.rows,
             fun <- fn ([id, address, ssh_host, is_active, created, updated]) ->
               Mapper.to_entity([
                id, 
                address, 
                ssh_host, 
                nil, 
                nil, 
                nil,
                is_active, 
                nil, 
                nil, 
                created, 
                updated
              ])
             end,
             list <- Enum.map(rows, fun),
             list <- Enum.map(list, fn ({_, entity}) -> entity end) do
          Success.new(list)
        else
          false -> Success.new([])
          {:exception, message} -> {:exception, message}
        end
      [] -> Exception.new("Database connection error")
      _ -> Exception.new("Database connection error")
    end
  end

  def get(_, _, _) do
    Error.new("Не валидные данные для получения списка плэйлистов")
  end
end
