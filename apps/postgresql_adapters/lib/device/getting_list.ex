defmodule PostgresqlAdapters.Device.GettingList do
  
  alias Core.Device.Ports.GetterList

  alias Core.Device.Entity, as: Device
  alias Core.User.Entity, as: User
  
  alias PostgresqlAdapters.Executor

  alias Core.Shared.Types.Pagination
  alias Core.Device.Types.Filter
  alias Core.Device.Types.Sort

  alias PostgresqlAdapters.Device.QueryBuilder

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
             fun <- fn ([id, ip, lat, long, desc, created]) ->
                %Device{
                  id: UUID.binary_to_string!(id),
                  ip: ip, 
                  latitude: Decimal.to_float(lat), 
                  longitude: Decimal.to_float(long), 
                  desc: desc,
                  created: created
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
    {:error, "Не валидные данные для получения списка записей об устройствах из базы данных"}
  end
end