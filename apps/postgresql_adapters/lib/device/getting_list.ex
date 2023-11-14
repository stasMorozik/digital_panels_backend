defmodule PostgresqlAdapters.Device.GettingList do
  alias Core.Device.Ports.GetterList

  alias Core.Device.Entity

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error
  alias Core.Shared.Types.Exception
  
  alias Core.Device.Types.Filter
  alias Core.Device.Types.Sort
  alias Core.Shared.Types.Pagination

  @behaviour GetterList

  @impl GetterList
  def get(%Filter{
    user_id: filter_by_user_id,
    is_active: filter_by_is_active, 
    address: filter_by_address, 
    ssh_host: filter_by_ssh_host, 
    created_f: filter_by_created_f,
    created_t: filter_by_created_t
  } = filter, %Sort{
    is_active: sort_by_is_active,
    created: sort_by_created
  } = sort, %Pagination{
    page: page,
    limit: limit
  } = pagi) do
    case :ets.lookup(:connections, "postgresql") do
      [{"postgresql", "", connection}] ->
        
        {"
          SELECT 
            d.id, d.address, d.ssh_host, d.is_active, d.created, d.updated
          FROM 
            relations_user_device AS rl_u_d
          JOIN 
            devices AS d ON d.id = rl_u_d.device_id
        ", []} |> where_user_id(filter) 
               |> and_where_address(filter)
               |> and_where_ssh_host(filter)
               |> and_where_is_active(filter)
               |> and_where_created_f(filter)
               |> and_where_created_t(filter)
               |> order_by_is_active(sort)
               |> order_by_created(sort)
               |> limit_offset(pagi)
               |> query(connection)
               |> mapper()

      [] -> Exception.new("Database connection error")
      _ -> Exception.new("Database connection error")
    end
  end

  def get(_, _, _) do
    Error.new("Не валидные данные для получения списка плэйлистов")
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

      order = if order == "asc" || order == "desc" do
        String.upcase(order)
      else
        "ASC"
      end

      query_string = query_string <> " ORDER BY d.is_active #{order}"

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

  defp query({query_string, data_list}, connection) do
    with {:ok, query} <- Postgrex.prepare(connection, "", query_string),
         {:ok, _, data} <- Postgrex.execute(connection, query, data_list),
         rows <- data.rows do
      {:ok, rows}
    else
      {:error, e} -> Exception.new(e.message)
    end
  end

  defp mapper({:ok, data}) do
    data = Enum.map(data, fn [id, address, ssh_host, is_active, created, updated] -> 
      %Entity{
        id: UUID.binary_to_string!(id),
        ssh_host: ssh_host,
        address: address,
        is_active: is_active,
        created: created,
        updated: updated
      }
    end)

    Success.new(data)
  end

  defp mapper({:error, message}) do
    {:error, message}
  end

  defp mapper({:exception, message}) do
    {:exception, message}
  end
end