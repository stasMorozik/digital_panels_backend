defmodule PostgresqlAdapters.Device.QueryBuilder do
  
  alias Core.Shared.Types.Pagination
  alias Core.Device.Types.Filter
  alias Core.Device.Types.Sort
  alias Core.User.Entity, as: User

  @query "
    SELECT 
      devices.id AS id,
      devices.ip AS ip,
      devices.latitude AS lat,
      devices.longitude AS long,
      devices.description AS desc,
      devices.is_active AS act,
      devices.created AS created
    FROM 
      relations_user_device 
    JOIN devices ON 
      relations_user_device.device_id = devices.id
  "

  def build(
    %Pagination{} = pagi, 
    %Filter{} = filter, 
    %Sort{} = sort, 
    %User{} = user
  ) do
    {@query, []} 
      |> where_user_id(user)
      |> and_where_ip(filter)
      |> and_where_latitude_f(filter)
      |> and_where_latitude_t(filter)
      |> and_where_longitude_f(filter)
      |> and_where_longitude_t(filter)
      |> and_where_description(filter)
      |> and_where_is_active(filter)
      |> and_where_created_f(filter)
      |> and_where_created_t(filter)
      |> order_by(sort)
      |> PostgresqlAdapters.Shared.Pagination.limit_offset(pagi)
  end

  defp where_user_id({query_string, data_list}, user) do
    data_list = data_list ++ [UUID.string_to_binary!(user.id)]

    query_string = query_string <> "WHERE relations_user_device.user_id = $#{length(data_list)}"
        
    {query_string, data_list}
  end

  defp and_where_ip({query_string, data_list}, filter) do
    case Map.get(filter, :ip) do
      nil -> {query_string, data_list}
      ip -> 
        data_list = data_list ++ ["%#{ip}%"]

        query_string = query_string <> " AND devices.ip ILIKE $#{length(data_list)}"

        {query_string, data_list}
    end
  end

  defp and_where_latitude_f({query_string, data_list}, filter) do
    case Map.get(filter, :latitude_f) do
      nil -> {query_string, data_list}
      latitude_f -> 
        data_list = data_list ++ [latitude_f]

        query_string = query_string <> " AND devices.latitude >= $#{length(data_list)}"

        {query_string, data_list}
    end
  end

  defp and_where_latitude_t({query_string, data_list}, filter) do
    case Map.get(filter, :latitude_t) do
      nil -> {query_string, data_list}
      latitude_t -> 
        data_list = data_list ++ [latitude_t]

        query_string = query_string <> " AND devices.latitude <= $#{length(data_list)}"

        {query_string, data_list}
    end
  end

  defp and_where_longitude_f({query_string, data_list}, filter) do
    case Map.get(filter, :longitude_f) do
      nil -> {query_string, data_list}
      longitude_f -> 
        data_list = data_list ++ [longitude_f]

        query_string = query_string <> " AND devices.longitude >= $#{length(data_list)}"

        {query_string, data_list}
    end
  end

  defp and_where_longitude_t({query_string, data_list}, filter) do
    case Map.get(filter, :longitude_t) do
      nil -> {query_string, data_list}
      longitude_t -> 
        data_list = data_list ++ [longitude_t]

        query_string = query_string <> " AND devices.longitude <= $#{length(data_list)}"

        {query_string, data_list}
    end
  end

  defp and_where_description({query_string, data_list}, filter) do
    case Map.get(filter, :description) do
      nil -> {query_string, data_list}
      description -> 
        data_list = data_list ++ ["%#{description}%"]

        query_string = query_string <> " AND devices.description ILIKE $#{length(data_list)}"

        {query_string, data_list}
    end
  end

  defp and_where_is_active({query_string, data_list}, filter) do
    case Map.get(filter, :is_active) do
      nil -> {query_string, data_list}
      is_active -> 
        data_list = data_list ++ [is_active]

        query_string = query_string <> " AND devices.is_active = $#{length(data_list)}"

        {query_string, data_list}
    end
  end

  defp and_where_created_f({query_string, data_list}, filter) do
    case Map.get(filter, :created_f) do
      nil -> {query_string, data_list}
      created_f -> 
        data_list = data_list ++ [created_f]

        query_string = query_string <> " AND devices.created >= $#{length(data_list)}"

        {query_string, data_list}
    end
  end

  defp and_where_created_t({query_string, data_list}, filter) do
    case Map.get(filter, :created_t) do
      nil -> {query_string, data_list}
      created_t -> 
        data_list = data_list ++ [created_t]

        query_string = query_string <> " AND devices.created <= $#{length(data_list)}"

        {query_string, data_list}
    end
  end

  defp order_by({query_string, data_list}, sort) do
    map = Map.from_struct(sort)
    list = Map.to_list(map)
    
    found = Enum.find(list, fn (tuple) -> 
      value = elem(tuple, 1)
      value != nil
    end)
    
    case found do
      nil -> {query_string, data_list}
      tuple -> 
        key = elem(tuple, 0)
        value = elem(tuple, 1)

        case value do
          nil -> {query_string, data_list}
          value -> {query_string <> " ORDER BY devices.#{key} #{value}", data_list}
        end
    end
  end
end