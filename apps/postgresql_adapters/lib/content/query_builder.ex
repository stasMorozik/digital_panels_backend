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
      |> order_by(sort)
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
          value -> {query_string <> " ORDER BY contents.#{key} #{value}", data_list}
        end
    end
  end
end