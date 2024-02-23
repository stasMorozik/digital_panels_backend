defmodule PostgresqlAdapters.File.GettingList do
  
  alias Core.File.Ports.GetterList

  alias Core.File.Entity, as: File
  alias Core.User.Entity, as: User
  
  alias PostgresqlAdapters.Executor

  alias Core.Shared.Types.Pagination
  alias Core.File.Types.Filter
  alias Core.File.Types.Sort

  alias PostgresqlAdapters.File.QueryBuilder

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
             rows <- result.rows,
             fun <- fn ([id, url, extension, type, size, created]) ->
               %File{
                  id: UUID.binary_to_string!(id),
                  url: url,
                  extension: extension,
                  type: type,
                  size: size,
                  created: created
               }
             end,
             list <- Enum.map(rows, fun) do
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
    {:error, "Не валидные данные для получения списка записей о файлах из базы данных"}
  end
end