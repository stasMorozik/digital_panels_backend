defmodule PostgresqlAdapters.Device.QueryBuilder do
  alias Core.Device.Types.Filter
  alias Core.Device.Types.Sort
  alias Core.Shared.Types.Pagination

  def build(%Filter{} = filter, %Sort{} = sort, %Pagination{} = pagi) do
    string = "
      SELECT 
        d.id, d.address, d.ssh_host, d.is_active, d.created, d.updated
      FROM 
        relations_user_device AS rl_u_d
      JOIN 
        devices AS d ON d.id = rl_u_d.device_id
    "

    {string, []} 
      |> where_user_id(filter) 
      |> and_where_address(filter)
      |> and_where_ssh_host(filter)
      |> and_where_is_active(filter)
      |> and_where_created_f(filter)
      |> and_where_created_t(filter)
      |> order_by_is_active(sort)
      |> order_by_created(sort)
      |> limit_offset(pagi)
  end

  defp where_user_id({query_string, data_list}, filter) do
    case Map.get(filter, :user_id) do
      nil -> {query_string, data_list}
      user_id -> 
        data_list = data_list ++ [user_id]

        query_string = query_string <> "WHERE rl_u_d.user_id = $#{length(data_list)}"
        
        {query_string, data_list}
    end
  end

  defp and_where_address({query_string, data_list}, filter) do
    case Map.get(filter, :address) do
      nil -> {query_string, data_list}
      address -> 
        data_list = data_list ++ ["%#{address}%"]

        query_string = query_string <> " AND d.address ILIKE $#{length(data_list)}"

        {query_string, data_list}
    end
  end

  defp and_where_ssh_host({query_string, data_list}, filter) do
    case Map.get(filter, :ssh_host) do
      nil -> {query_string, data_list}
      ssh_host -> 
        data_list = data_list ++ ["%#{ssh_host}%"]

        query_string = query_string <> " AND d.ssh_host ILIKE $#{length(data_list)}"

        {query_string, data_list}
    end
  end

  defp and_where_is_active({query_string, data_list}, filter) do
    case Map.get(filter, :is_active) do
      nil -> {query_string, data_list}
      is_active -> 
        data_list = data_list ++ [is_active]

        query_string = query_string <> " AND d.is_active = $#{length(data_list)}"

        {query_string, data_list}
    end
  end

  defp and_where_created_f({query_string, data_list}, filter) do
    case Map.get(filter, :created_f) do
      nil -> {query_string, data_list}
      created_f -> 
        data_list = data_list ++ [created_f]

        query_string = query_string <> " AND d.created >= $#{length(data_list)}"

        {query_string, data_list}
    end
  end

  defp and_where_created_t({query_string, data_list}, filter) do
    case Map.get(filter, :created_t) do
      nil -> {query_string, data_list}
      created_t -> 
        data_list = data_list ++ [created_t]

        query_string = query_string <> " AND d.created <= $#{length(data_list)}"

        {query_string, data_list}
    end
  end

  defp order_by_is_active({query_string, data_list}, sort) do
    with order <- Map.get(sort, :is_active),
         false <- order == nil do

      query_string = query_string <> " ORDER BY d.is_active #{order}"

      {query_string, data_list}
    else
      true -> {query_string, data_list}
    end
  end

  defp order_by_created({query_string, data_list}, sort) do
    with order <- Map.get(sort, :created),
         false <- order == nil do

      query_string = query_string <> " ORDER BY d.created #{order}"

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