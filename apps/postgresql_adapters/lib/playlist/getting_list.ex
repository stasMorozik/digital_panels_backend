defmodule PostgresqlAdapters.Playlist.GettingList do
  alias Core.Playlist.Ports.GetterList

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error
  alias Core.Shared.Types.Exception
  
  alias Core.Playlist.Types.Filter
  alias Core.Playlist.Types.Sort
  alias Core.Shared.Types.Pagination

  alias PostgresqlAdapters.Playlist.QueryBuilder
  alias PostgresqlAdapters.Playlist.Mapper
  alias PostgresqlAdapters.Executor

  @behaviour GetterList

  @impl GetterList
  def get(%Filter{} = filter, %Sort{} = sort, %Pagination{} = pagi) do
    case :ets.lookup(:connections, "postgresql") do
      [{"postgresql", "", connection}] ->
        with {query, data_list} <- QueryBuilder.build(filter, sort, pagi),
             {:ok, result} <- Executor.execute(query, data_list),
             true <- result.num_rows > 0,
             rows <- result.rows,
             fun <- fn ([id, name, created, updated]) ->
               Mapper.to_entity([id, name, nil, created, updated])
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
