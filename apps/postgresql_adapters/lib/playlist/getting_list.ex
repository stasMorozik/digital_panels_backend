defmodule PostgresqlAdapters.Playlist.GettingList do
  
  alias Core.Playlist.Ports.GetterList

  alias Core.Playlist.Entity, as: Playlist
  alias Core.User.Entity, as: User
  
  alias PostgresqlAdapters.Executor

  alias Core.Shared.Types.Pagination
  alias Core.Playlist.Types.Filter
  alias Core.Playlist.Types.Sort

  alias PostgresqlAdapters.Playlist.QueryBuilder

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
             fun <- fn ([id, name, sum, created, updated]) ->
               %Playlist{
                  id: UUID.binary_to_string!(id),
                  name: name,
                  sum: sum,
                  created: created,
                  updated: updated
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
    {:error, "Не валидные данные для получения списка записей о группах из базы данных"}
  end
end