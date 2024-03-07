defmodule PostgresqlAdapters.File.QueryBuilder do
  
  alias Core.Shared.Types.Pagination
  alias Core.File.Types.Filter
  alias Core.File.Types.Sort
  alias Core.User.Entity, as: User

  @query "
    SELECT 
      files.id,  
      files.url, 
      files.extension, 
      files.type, 
      files.size, 
      files.created
    FROM 
      relations_user_file 
    JOIN files ON 
      relations_user_file.file_id = files.id
  "

  def build(
    %Pagination{} = pagi, 
    %Filter{} = filter, 
    %Sort{} = sort, 
    %User{} = user
  ) do
    {@query, []} 
      |> where_user_id(user)
      |> and_where_type(filter)
      |> and_where_url(filter)
      |> and_where_extension(filter)
      |> and_where_size(filter)
      |> and_where_created_f(filter)
      |> and_where_created_t(filter)
      |> order_by(sort)
      |> PostgresqlAdapters.Shared.Pagination.limit_offset(pagi)
  end

  defp where_user_id({query_string, data_list}, user) do
    data_list = data_list ++ [UUID.string_to_binary!(user.id)]

    query_string = query_string <> "WHERE relations_user_file.user_id = $#{length(data_list)}"
        
    {query_string, data_list}
  end

  defp and_where_type({query_string, data_list}, filter) do
    case Map.get(filter, :type) do
      nil -> {query_string, data_list}
      type -> 
        data_list = data_list ++ [type]

        query_string = query_string <> " AND files.type = $#{length(data_list)}"

        {query_string, data_list}
    end
  end

  defp and_where_url({query_string, data_list}, filter) do
    case Map.get(filter, :url) do
      nil -> {query_string, data_list}
      url -> 
        data_list = data_list ++ ["%#{url}%"]

        query_string = query_string <> " AND files.url ILIKE $#{length(data_list)}"

        {query_string, data_list}
    end
  end

  defp and_where_extension({query_string, data_list}, filter) do
    case Map.get(filter, :extension) do
      nil -> {query_string, data_list}
      extension -> 
        data_list = data_list ++ [extension]

        query_string = query_string <> " AND files.extension = $#{length(data_list)}"

        {query_string, data_list}
    end
  end

  defp and_where_size({query_string, data_list}, filter) do
    case Map.get(filter, :size) do
      nil -> {query_string, data_list}
      size -> 
        data_list = data_list ++ [size]

        query_string = query_string <> " AND files.size = $#{length(data_list)}"

        {query_string, data_list}
    end
  end

  defp and_where_created_f({query_string, data_list}, filter) do
    case Map.get(filter, :created_f) do
      nil -> {query_string, data_list}
      created_f -> 
        data_list = data_list ++ [created_f]

        query_string = query_string <> " AND files.created >= $#{length(data_list)}"

        {query_string, data_list}
    end
  end

  defp and_where_created_t({query_string, data_list}, filter) do
    case Map.get(filter, :created_t) do
      nil -> {query_string, data_list}
      created_t -> 
        data_list = data_list ++ [created_t]

        query_string = query_string <> " AND files.created <= $#{length(data_list)}"

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
          value -> {query_string <> " ORDER BY files.#{key} #{value}", data_list}
        end
    end
  end
end