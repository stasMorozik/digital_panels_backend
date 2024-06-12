defmodule Core.Task.Builders.Filter do
  

  alias Core.Shared.Validators.Date
  alias Core.Shared.Validators.Identifier

  alias Core.Shared.Builders.BuilderProperties

  alias Core.Task.Validators.Name
  alias Core.Task.Validators.Type
  alias Core.Task.Validators.TypeDay
  alias Core.Task.Validators.TimePoints

  @spec build(map()) :: Core.Shared.Types.Success.t() | Core.Shared.Types.Error.t()
  def build(%{} = args) do
    simple_setter = fn (entity, key, value) -> 
      Map.put(entity, key, value) 
    end

    type_day_setter = fn (entity, key, {_, day}) -> 
      Map.put(entity, key, day) 
    end

    time_points_setter = fn (entity, key, {hour, minute}) ->
      hour = case hour == 24 do
        true -> 0
        false -> hour
      end

      minutes = (hour * 60) + minute

      Map.put(entity, key, minutes)
    end

    filter()
      |> name(Map.get(args, :name), simple_setter)
      |> type(Map.get(args, :type), simple_setter)
      |> day({Map.get(args, :type), Map.get(args, :day)}, type_day_setter)
      |> group(Map.get(args, :group), simple_setter)
      |> start_hm({Map.get(args, :start_hour), Map.get(args, :start_minute)}, time_points_setter)
      |> end_hm({Map.get(args, :end_hour), Map.get(args, :end_minute)}, time_points_setter)
      |> created_f(Map.get(args, :created_f), simple_setter)
      |> created_t(Map.get(args, :created_t), simple_setter)
  end

  def build(_) do
    {:error, "Невалидные данные для фильтра"}
  end

  defp filter do
    {:ok, %Core.Task.Types.Filter{}}
  end

  defp name({:ok, filter}, name, setter) do
    case name do
      nil -> {:ok, filter}
      name -> BuilderProperties.build({:ok, filter}, Name, setter, :name, name)
    end
  end

  defp name({:error, message}, _, _) do
    {:error, message}
  end

  defp type({:ok, filter}, type, setter) do
    case type do
      nil -> {:ok, filter}
      type -> BuilderProperties.build({:ok, filter}, Type, setter, :type, type)
    end
  end

  defp type({:error, message}, _, _) do
    {:error, message}
  end

  defp day({:ok, filter}, {type, day}, setter) do
    with false <- type == nil,
         false <- day == nil do
      BuilderProperties.build({:ok, filter}, TypeDay, setter, :day, {type, day})
    else
      true -> {:ok, filter}
    end
  end

  defp day({:error, message}, _, _) do
    {:error, message}
  end

  defp group({:ok, filter}, group, setter) do
    case group do
      nil -> {:ok, filter}
      group -> BuilderProperties.build({:ok, filter}, Identifier, setter, :group, group)
    end
  end

  defp group({:error, message}, _, _) do
    {:error, message}
  end

  defp created_f({:ok, filter}, created_f, setter) do
    case created_f do
      nil -> {:ok, filter}
      created_f -> BuilderProperties.build({:ok, filter}, Date, setter, :created_f, created_f)
    end
  end

  defp created_f({:error, message}, _, _) do
    {:error, message}
  end

  defp created_t({:ok, filter}, created_t, setter) do
    case created_t do
      nil -> {:ok, filter}
      created_t -> BuilderProperties.build({:ok, filter}, Date, setter, :created_t, created_t)
    end
  end

  defp created_t({:error, message}, _, _) do
    {:error, message}
  end

  defp start_hm({:ok, filter}, {start_hour, start_minute}, setter) do
    with false <- start_hour == nil,
         false <- start_minute == nil do
      BuilderProperties.build({:ok, filter}, TimePoints, setter, :start, {start_hour, start_minute})
    else
      true -> {:ok, filter}
    end
  end

  defp start_hm({:error, message}, _, _) do
    {:error, message}
  end

  defp end_hm({:ok, filter}, {end_hour, end_minute}, setter) do
    with false <- end_hour == nil,
         false <- end_minute == nil do
      BuilderProperties.build({:ok, filter}, TimePoints, setter, :end, {end_hour, end_minute})
    else
      true -> {:ok, filter}
    end
  end

  defp end_hm({:error, message}, _, _) do
    {:error, message}
  end
end