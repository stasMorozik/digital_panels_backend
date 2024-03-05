defmodule PostgresqlAdapters.Task.QueryBuilder do
  
  alias Core.Shared.Types.Pagination
  alias Core.Task.Types.Filter
  alias Core.Task.Types.Sort
  alias Core.User.Entity, as: User

  @query "
    SELECT 
      tasks.id AS task_id,
      tasks.name AS task_nm,
      tasks.type AS task_tp,
      tasks.day AS task_day,
      tasks.start_hour AS task_start_h,
      tasks.end_hour AS task_end_h,
      tasks.start_minute AS task_start_m,
      tasks.end_minute AS task_end_m,
      tasks.start_hm AS task_start_hm,
      tasks.end_hm  AS task_end_hm,
      tasks.sum  AS task_sum,
      tasks.created AS task_cr,
      tasks.updated AS task_upd,
      groups.id AS gr_id,
      groups.name AS gr_nm,
      groups.created AS gr_cr,
      groups.updated AS gr_upd
    FROM 
      relations_user_task 
    JOIN tasks ON 
      relations_user_task.task_id = tasks.id
    JOIN groups ON
      tasks.group_id = groups.id
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
      |> and_where_type(filter)
      |> and_where_day(filter)
      |> and_where_group(filter)
      |> and_where_start(filter)
      |> and_where_end(filter)
      |> and_where_created_f(filter)
      |> and_where_created_t(filter)
      |> order_by_name(sort)
      |> order_by_type(sort)
      |> order_by_created(sort)
      |> PostgresqlAdapters.Shared.Pagination.limit_offset(pagi)
  end

  defp where_user_id({query_string, data_list}, user) do
    data_list = data_list ++ [UUID.string_to_binary!(user.id)]

    query_string = query_string <> "WHERE relations_user_task.user_id = $#{length(data_list)}"
        
    {query_string, data_list}
  end

  defp and_where_name({query_string, data_list}, filter) do
    case Map.get(filter, :name) do
      nil -> {query_string, data_list}
      name -> 
        data_list = data_list ++ ["%#{name}%"]

        query_string = query_string <> " AND tasks.name ILIKE $#{length(data_list)}"

        {query_string, data_list}
    end
  end

  defp and_where_type({query_string, data_list}, filter) do
    case Map.get(filter, :type) do
      nil -> {query_string, data_list}
      type -> 
        data_list = data_list ++ [type]

        query_string = query_string <> " AND tasks.type = $#{length(data_list)}"

        {query_string, data_list}
    end
  end

  defp and_where_day({query_string, data_list}, filter) do
    case Map.fetch(filter, :day) do
      :error -> {query_string, data_list}
      {:ok, day} -> 
        bool = day == nil

        data_list = case bool do
          true -> data_list
          false -> data_list ++ [day]
        end

        query_string = case bool do
          true -> query_string <> " AND tasks.day IS NULL" 
          false -> query_string <> " AND tasks.day = $#{length(data_list)}"
        end

        {query_string, data_list}
    end
  end

  defp and_where_group({query_string, data_list}, filter) do
    case Map.get(filter, :group) do
      nil -> {query_string, data_list}
      group -> 
        data_list = data_list ++ [UUID.string_to_binary!(group)]

        query_string = query_string <> " AND tasks.group_id = $#{length(data_list)}"

        {query_string, data_list}
    end
  end

  defp and_where_start({query_string, data_list}, filter) do
    case Map.get(filter, :start) do
      nil -> {query_string, data_list}
      start_hm -> 
        data_list = data_list ++ [start_hm]

        query_string = query_string <> " AND tasks.start_hm >= $#{length(data_list)}"

        {query_string, data_list}
    end
  end

  defp and_where_end({query_string, data_list}, filter) do
    case Map.get(filter, :end) do
      nil -> {query_string, data_list}
      end_hm -> 
        data_list = data_list ++ [end_hm]

        query_string = query_string <> " AND tasks.end_hm <= $#{length(data_list)}"

        {query_string, data_list}
    end
  end

  defp and_where_created_f({query_string, data_list}, filter) do
    case Map.get(filter, :created_f) do
      nil -> {query_string, data_list}
      created_f -> 
        data_list = data_list ++ [created_f]

        query_string = query_string <> " AND tasks.created >= $#{length(data_list)}"

        {query_string, data_list}
    end
  end

  defp and_where_created_t({query_string, data_list}, filter) do
    case Map.get(filter, :created_t) do
      nil -> {query_string, data_list}
      created_t -> 
        data_list = data_list ++ [created_t]

        query_string = query_string <> " AND tasks.created <= $#{length(data_list)}"

        {query_string, data_list}
    end
  end

  defp order_by_name({query_string, data_list}, sort) do
    with order <- Map.get(sort, :name),
         false <- order == nil do

      query_string = query_string <> " ORDER BY tasks.name #{order}"

      {query_string, data_list}
    else
      true -> {query_string, data_list}
    end
  end

  defp order_by_type({query_string, data_list}, sort) do
    with order <- Map.get(sort, :type),
         false <- order == nil do

      query_string = query_string <> " ORDER BY tasks.type #{order}"

      {query_string, data_list}
    else
      true -> {query_string, data_list}
    end
  end

  defp order_by_created({query_string, data_list}, sort) do
    with order <- Map.get(sort, :created),
         false <- order == nil do

      query_string = query_string <> " ORDER BY tasks.created #{order}"

      {query_string, data_list}
    else
      true -> {query_string, data_list}
    end
  end
end