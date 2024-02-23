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
      |> order_by_size(sort)
      |> order_by_type(sort)
      |> order_by_created(sort)
      |> PostgresqlAdapters.Shared.Pagination.limit_offset(pagi)
  end

  defp where_user_id({query_string, data_list}, user) do
    data_list = data_list ++ [UUID.binary_to_string!(user.id)]

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

  defp order_by_size({query_string, data_list}, sort) do
    with order <- Map.get(sort, :size),
         false <- order == nil do

      query_string = query_string <> " ORDER BY files.size #{order}"

      {query_string, data_list}
    else
      true -> {query_string, data_list}
    end
  end

  defp order_by_type({query_string, data_list}, sort) do
    with order <- Map.get(sort, :type),
         false <- order == nil do

      query_string = query_string <> " ORDER BY files.type #{order}"

      {query_string, data_list}
    else
      true -> {query_string, data_list}
    end
  end

  defp order_by_created({query_string, data_list}, sort) do
    with order <- Map.get(sort, :created),
         false <- order == nil do

      query_string = query_string <> " ORDER BY files.created #{order}"

      {query_string, data_list}
    else
      true -> {query_string, data_list}
    end
  end
end