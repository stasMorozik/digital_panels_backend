defmodule PostgresqlAdapters.Playlist.GettingList do
  alias Core.Playlist.Ports.GetterList

  alias Core.Playlist.Entity, as: PlaylistEntity
  alias Core.Content.Entity, as: ContentEntity
  alias Core.File.Entity, as: FileEntity

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error
  
  alias Core.Playlist.Types.Filter
  alias Core.Playlist.Types.Sort
  alias Core.Shared.Types.Pagination

  @behaviour GetterList

  @impl GetterList
  def get(%Filter{
    user_id: filter_by_user_id,
    name: filter_by_name,
    created_f: filter_by_created_f,
    created_t: filter_by_created_t,
    updated_f: filter_by_updated_f,
    updated_t: filter_by_updated_t
  }, %Sort{
    name: sort_by_name,
    created: sort_by_created,
    updated: sort_by_updated
  }, %Pagination{
    page: page,
    limit: limit
  }) do
    case :ets.lookup(:connections, "postgresql") do
      [{"postgresql", "", connection}] ->
        
        filter = %Filter{
          user_id: filter_by_user_id,
          name: filter_by_name,
          created_f: filter_by_created_f,
          created_t: filter_by_created_t,
          updated_f: filter_by_updated_f,
          updated_t: filter_by_updated_t
        }

        sort = %Sort{
          name: sort_by_name,
          created: sort_by_created,
          updated: sort_by_updated
        }

        pagi = %Pagination{
          page: page,
          limit: limit
        }

        {result, data} = {"
          SELECT 
            pl.id, pl.name, pl.created, pl.updated
          FROM 
            relations_user_playlist AS rl_u_p
          JOIN 
            playlists AS pl ON pl.id = rl_u_p.playlist_id
        ", []} |> where_user_id(filter) 
               |> and_where_name(filter)
               |> and_where_created_f(filter)
               |> and_where_created_t(filter)
               |> and_where_updated_f(filter)
               |> and_where_updated_t(filter)
               |> order_by_name(sort)
               |> order_by_created(sort)
               |> order_by_updated(sort)
               |> limit_offset(pagi)
               |> query(connection)
               |> mapper()

        Success.new(true)


      [] -> Error.new("Database connection error")
      _ -> Error.new("Database connection error")
    end
  end

  def get(_, _, _) do
    Error.new("Не валидные данные для получения списка плэйлистов")
  end

  defp where_user_id({query_string, data_list}, filter) do
    case Map.get(filter, :user_id) do
      nil -> {query_string, data_list}
      user_id -> 
        data_list = data_list ++ [UUID.string_to_binary!(user_id)]

        query_string = query_string <> "WHERE rl_u_p.user_id = $#{length(data_list)}"
        
        {query_string, data_list}
    end
  end

  defp and_where_name({query_string, data_list}, filter) do
    case Map.get(filter, :name) do
      nil -> {query_string, data_list}
      name -> 
        data_list = data_list ++ ["%#{name}%"]

        query_string = query_string <> " AND pl.name LIKE $#{length(data_list)}"

        {query_string, data_list}
    end
  end

  defp and_where_created_f({query_string, data_list}, filter) do
    case Map.get(filter, :created_f) do
      nil -> {query_string, data_list}
      created_f -> 
        data_list = data_list ++ [created_f]

        query_string = query_string <> " AND pl.created >= $#{length(data_list)}"

        {query_string, data_list}
    end
  end

  defp and_where_created_t({query_string, data_list}, filter) do
    case Map.get(filter, :created_t) do
      nil -> {query_string, data_list}
      created_t -> 
        data_list = data_list ++ [created_t]

        query_string = query_string <> " AND pl.created <= $#{length(data_list)}"

        {query_string, data_list}
    end
  end

  defp and_where_updated_f({query_string, data_list}, filter) do
    case Map.get(filter, :updated_f) do
      nil -> {query_string, data_list}
      updated_f -> 
        data_list = data_list ++ [updated_f]

        query_string = query_string <> " AND pl.updated >= $#{length(data_list)}"

        {query_string, data_list}
    end
  end

  defp and_where_updated_t({query_string, data_list}, filter) do
    case Map.get(filter, :updated_t) do
      nil -> {query_string, data_list}
      updated_t -> 
        data_list = data_list ++ [updated_t]

        query_string = query_string <> " AND pl.updated <= $#{length(data_list)}"

        {query_string, data_list}
    end
  end

  defp order_by_name({query_string, data_list}, sort) do
    with order <- Map.get(sort, :name),
         false <- order == nil do

      order = if order == "asc" || order == "desc" do
        String.upcase(order)
      else
        "ASC"
      end

      query_string = query_string <> " ORDER BY pl.name #{order}"

      {query_string, data_list}
    else
      true -> {query_string, data_list}
    end
  end

  defp order_by_created({query_string, data_list}, sort) do
    with order <- Map.get(sort, :created),
         false <- order == nil do

      order = if order == "asc" || order == "desc" do
        String.upcase(order)
      else
        "ASC"
      end

      query_string = query_string <> " ORDER BY pl.created #{order}"

      {query_string, data_list}
    else
      true -> {query_string, data_list}
    end
  end

  defp order_by_updated({query_string, data_list}, sort) do
    with order <- Map.get(sort, :updated),
         false <- order == nil do

      order = if order == "asc" || order == "desc" do
        String.upcase(order)
      else
        "ASC"
      end

      query_string = query_string <> " ORDER BY pl.updated #{order}"

      {query_string, data_list}
    else
      true -> {query_string, data_list}
    end
  end

  defp limit_offset({query_string, data_list}, pagi) do
    offset = cond do
      pagi.page == 1 -> 0
      pagi.page > 1 -> pagi.limit * (pagi.page-1)
    end

    data_list = data_list ++ [pagi.limit]

    query_string = query_string <> " LIMIT $#{length(data_list)}"

    data_list = data_list ++ [offset]

    query_string = query_string <> " OFFSET $#{length(data_list)}"

    {query_string, data_list}
  end

  defp query({query_string, data_list}, connection) do
    with {:ok, query} <- Postgrex.prepare(connection, "", query_string),
         {:ok, _, data} <- Postgrex.execute(connection, query, data_list),
         rows <- data.rows do
      {:ok, rows}
    else
      {:error, _} -> Error.new("Ошибка запроса к базе данных")
    end
  end

  defp mapper({:ok, data}) do
    IO.inspect(data)

    data = Enum.map(data, fn [id, name, created, updated] -> 
      %PlaylistEntity{
        id: id,
        name: name,
        created: created,
        updated: updated
      }
    end)

    {:ok, data}
  end

  defp mapper({:error, message}) do
    {:error, message}
  end
end