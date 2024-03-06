defmodule PostgresqlAdapters.Assembly.QueryBuilder do
  
  alias Core.Shared.Types.Pagination
  alias Core.Assembly.Types.Filter
  alias Core.Assembly.Types.Sort
  alias Core.User.Entity, as: User

  @query "
    SELECT 
      assemblies.id AS a_id,
      assemblies.url AS a_url,
      assemblies.type AS a_type,
      assemblies.status AS a_st,
      assemblies.created AS a_created,
      groups.id AS gr_id, 
      groups.name AS gr_name
    FROM 
      relations_user_assembly 
    JOIN assemblies ON 
      relations_user_assembly.assembly_id = assemblies.id
    LEFT JOIN groups ON
      assemblies.group_id = groups.id
  "

  def build(
    %Pagination{} = pagi, 
    %Filter{} = filter, 
    %Sort{} = sort, 
    %User{} = user
  ) do
    {@query, []} 
      |> where_user_id(user)
      |> and_where_url(filter)
      |> and_where_type(filter)
      |> and_where_group(filter)
      |> and_where_status(filter)
      |> and_where_created_f(filter)
      |> and_where_created_t(filter)
      |> order_by_type(sort)
      |> order_by_created(sort)
      |> PostgresqlAdapters.Shared.Pagination.limit_offset(pagi)
  end

  defp where_user_id({query_string, data_list}, user) do
    data_list = data_list ++ [UUID.string_to_binary!(user.id)]

    query_string = query_string <> "WHERE relations_user_assembly.user_id = $#{length(data_list)}"
        
    {query_string, data_list}
  end

  defp and_where_url({query_string, data_list}, filter) do
    case Map.get(filter, :url) do
      nil -> {query_string, data_list}
      url -> 
        data_list = data_list ++ ["%#{url}%"]

        query_string = query_string <> " AND assemblies.url ILIKE $#{length(data_list)}"

        {query_string, data_list}
    end
  end

  defp and_where_type({query_string, data_list}, filter) do
    case Map.get(filter, :type) do
      nil -> {query_string, data_list}
      type -> 
        data_list = data_list ++ [type]

        query_string = query_string <> " AND assemblies.type = $#{length(data_list)}"

        {query_string, data_list}
    end
  end

  defp and_where_group({query_string, data_list}, filter) do
    case Map.get(filter, :group) do
      nil -> {query_string, data_list}
      group -> 
        data_list = data_list ++ [group]

        query_string = query_string <> " AND assemblies.group_id = $#{length(data_list)}"

        {query_string, data_list}
    end
  end

  defp and_where_status({query_string, data_list}, filter) do
    case Map.get(filter, :status) do
      nil -> {query_string, data_list}
      status -> 
        data_list = data_list ++ [status]

        query_string = query_string <> " AND assemblies.status = $#{length(data_list)}"

        {query_string, data_list}
    end
  end

  defp and_where_created_f({query_string, data_list}, filter) do
    case Map.get(filter, :created_f) do
      nil -> {query_string, data_list}
      created_f -> 
        data_list = data_list ++ [created_f]

        query_string = query_string <> " AND assemblies.created >= $#{length(data_list)}"

        {query_string, data_list}
    end
  end

  defp and_where_created_t({query_string, data_list}, filter) do
    case Map.get(filter, :created_t) do
      nil -> {query_string, data_list}
      created_t -> 
        data_list = data_list ++ [created_t]

        query_string = query_string <> " AND assemblies.created <= $#{length(data_list)}"

        {query_string, data_list}
    end
  end

  defp order_by_type({query_string, data_list}, sort) do
    with order <- Map.get(sort, :type),
         false <- order == nil do

      query_string = query_string <> " ORDER BY assemblies.type #{order}"

      {query_string, data_list}
    else
      true -> {query_string, data_list}
    end
  end

  defp order_by_created({query_string, data_list}, sort) do
    with order <- Map.get(sort, :created),
         false <- order == nil do

      query_string = query_string <> " ORDER BY assemblies.created #{order}"

      {query_string, data_list}
    else
      true -> {query_string, data_list}
    end
  end
end