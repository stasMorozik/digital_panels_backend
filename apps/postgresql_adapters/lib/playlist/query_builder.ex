defmodule PostgresqlAdapters.Playlist.QueryBuilder do
  alias Core.Playlist.Types.Filter
  alias Core.Playlist.Types.Sort
  alias Core.Shared.Types.Pagination
  
  def build(%Filter{} = filter, %Sort{} = sort, %Pagination{} = pagi)
    string = "
      SELECT 
        pl.id, pl.name, pl.created, pl.updated
      FROM 
        relations_user_playlist AS rl_u_p
      JOIN 
        playlists AS pl ON pl.id = rl_u_p.playlist_id
    "

    {string, []} 
      |> where_user_id(filter) 
      |> and_where_name(filter)
      |> and_where_created_f(filter)
      |> and_where_created_t(filter)
      |> order_by_name(sort)
      |> order_by_created(sort)
      |> limit_offset(pagi)
  end

  defp where_user_id({query_string, data_list}, filter) do
    case Map.get(filter, :user_id) do
      nil -> {query_string, data_list}
      user_id -> 
        data_list = data_list ++ [user_id]

        query_string = query_string <> "WHERE rl_u_p.user_id = $#{length(data_list)}"
        
        {query_string, data_list}
    end
  end

  defp and_where_name({query_string, data_list}, filter) do
    case Map.get(filter, :name) do
      nil -> {query_string, data_list}
      name -> 
        data_list = data_list ++ ["%#{name}%"]

        query_string = query_string <> " AND pl.name ILIKE $#{length(data_list)}"

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

  defp order_by_name({query_string, data_list}, sort) do
    with order <- Map.get(sort, :name),
         false <- order == nil do

      query_string = query_string <> " ORDER BY pl.name #{order}"

      {query_string, data_list}
    else
      true -> {query_string, data_list}
    end
  end

  defp order_by_created({query_string, data_list}, sort) do
    with order <- Map.get(sort, :created),
         false <- order == nil do

      query_string = query_string <> " ORDER BY pl.created #{order}"

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
end