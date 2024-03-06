defmodule PostgresqlAdapters.Content.QueryBuilder do
  
  alias Core.Shared.Types.Pagination
  alias Core.Content.Types.Filter
  alias Core.Content.Types.Sort
  alias Core.User.Entity, as: User

  @query "
    SELECT 
      contents.id, 
      contents.name, 
      contents.duration,
      contents.created,
      contents.updated
    FROM 
      relations_user_content 
    JOIN contents ON 
      relations_user_content.content_id = contents.id
  "

  def build(
    %Pagination{} = pagi, 
    %Filter{} = filter, 
    %Sort{} = sort, 
    %User{} = user
  ) do
    {@query, []} 
      |> where_user_id(user)
      |> and_where_name(filter)
      |> and_where_duration_f(filter)
      |> and_where_duration_t(filter)
      |> and_where_created_f(filter)
      |> and_where_created_t(filter)
      |> order_by_name(sort)
      |> order_by_duration(sort)
      |> order_by_created(sort)
      |> PostgresqlAdapters.Shared.Pagination.limit_offset(pagi)
  end

  defp where_user_id({query_string, data_list}, user) do
    data_list = data_list ++ [UUID.string_to_binary!(user.id)]

    query_string = query_string <> "WHERE relations_user_content.user_id = $#{length(data_list)}"
        
    {query_string, data_list}
  end

  defp and_where_name({query_string, data_list}, filter) do
    case Map.get(filter, :name) do
      nil -> {query_string, data_list}
      name -> 
        data_list = data_list ++ ["%#{name}%"]

        query_string = query_string <> " AND contents.name ILIKE $#{length(data_list)}"

        {query_string, data_list}
    end
  end

  defp and_where_duration_f({query_string, data_list}, filter) do
    case Map.get(filter, :duration_f) do
      nil -> {query_string, data_list}
      duration_f -> 
        data_list = data_list ++ [duration_f]

        query_string = query_string <> " AND contents.duration >= $#{length(data_list)}"

        {query_string, data_list}
    end
  end

  defp and_where_duration_t({query_string, data_list}, filter) do
    case Map.get(filter, :duration_t) do
      nil -> {query_string, data_list}
      duration_t -> 
        data_list = data_list ++ [duration_t]

        query_string = query_string <> " AND contents.duration <= $#{length(data_list)}"

        {query_string, data_list}
    end
  end

  defp and_where_created_f({query_string, data_list}, filter) do
    case Map.get(filter, :created_f) do
      nil -> {query_string, data_list}
      created_f -> 
        data_list = data_list ++ [created_f]

        query_string = query_string <> " AND contents.created >= $#{length(data_list)}"

        {query_string, data_list}
    end
  end

  defp and_where_created_t({query_string, data_list}, filter) do
    case Map.get(filter, :created_t) do
      nil -> {query_string, data_list}
      created_t -> 
        data_list = data_list ++ [created_t]

        query_string = query_string <> " AND contents.created <= $#{length(data_list)}"

        {query_string, data_list}
    end
  end

  defp order_by_name({query_string, data_list}, sort) do
    with order <- Map.get(sort, :name),
         false <- order == nil do

      query_string = query_string <> " ORDER BY contents.name #{order}"

      {query_string, data_list}
    else
      true -> {query_string, data_list}
    end
  end

  defp order_by_duration({query_string, data_list}, sort) do
    with order <- Map.get(sort, :duration),
         false <- order == nil do

      query_string = query_string <> " ORDER BY contents.duration #{order}"

      {query_string, data_list}
    else
      true -> {query_string, data_list}
    end
  end

  defp order_by_created({query_string, data_list}, sort) do
    with order <- Map.get(sort, :created),
         false <- order == nil do

      query_string = query_string <> " ORDER BY contents.created #{order}"

      {query_string, data_list}
    else
      true -> {query_string, data_list}
    end
  end
end