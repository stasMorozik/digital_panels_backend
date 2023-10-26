defmodule PostgresqlAdapters.Device.GettingList do
  alias Core.Device.Ports.GetterList

  alias Core.Device.Entity

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error
  
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
    created_t: filter_by_created_t,
    updated_f: filter_by_updated_f,
    updated_t: filter_by_updated_t,
  }, %Sort{
    is_active: sort_by_is_active,
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
          is_active: filter_by_is_active, 
          address: filter_by_address, 
          ssh_host: filter_by_ssh_host, 
          created_f: filter_by_created_f,
          created_t: filter_by_created_t,
          updated_f: filter_by_updated_f,
          updated_t: filter_by_updated_t,
        }

        sort = %Sort{
          is_active: sort_by_is_active,
          created: sort_by_created,
          updated: sort_by_updated
        }

        pagi = %Pagination{
          page: page,
          limit: limit
        }

        {"
          SELECT 
            d.id, d.address, d.ssh_port, d.ssh_host, d.ssh_user,
            d.ssh_password, d.longitude, d.latitude, d.is_active,
            d.created, d.updated
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
               |> and_where_updated_f(filter)
               |> and_where_updated_t(filter)
               |> order_by_is_active(sort)
               |> order_by_created(sort)
               |> order_by_updated(sort)
               |> limit_offset(pagi)
               |> query(connection)
               |> mapper()

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

  defp and_where_updated_f({query_string, data_list}, filter) do
    case Map.get(filter, :updated_f) do
      nil -> {query_string, data_list}
      updated_f -> 
        data_list = data_list ++ [updated_f]

        query_string = query_string <> " AND d.updated >= $#{length(data_list)}"

        {query_string, data_list}
    end
  end

  defp and_where_updated_t({query_string, data_list}, filter) do
    case Map.get(filter, :updated_t) do
      nil -> {query_string, data_list}
      updated_t -> 
        data_list = data_list ++ [updated_t]

        query_string = query_string <> " AND d.updated <= $#{length(data_list)}"

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

  defp order_by_updated({query_string, data_list}, sort) do
    with order <- Map.get(sort, :updated),
         false <- order == nil do

      order = if order == "asc" || order == "desc" do
        String.upcase(order)
      else
        "ASC"
      end

      query_string = query_string <> " ORDER BY d.updated #{order}"

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
    data = Enum.map(data, fn [id, name, created, updated] -> 
      %PlaylistEntity{
        id: UUID.binary_to_string!(id),
        name: name,
        created: created,
        updated: updated
      }
    end)

    Success.new(data)
  end

  defp mapper({:error, message}) do
    {:error, message}
  end
end