defmodule Core.Task.Builders.Filter do
  
  alias Core.Task.Builders.Name
  alias Core.Task.Builders.Type
  alias Core.Task.Builders.Start
  alias Core.Task.Builders.End
  alias Core.Shared.Validators.Date
  alias Core.Shared.Validators.Identifier

  @spec build(map()) :: Core.Shared.Types.Success.t() | Core.Shared.Types.Error.t()
  def build(%{} = args) do
    filter()
      |> name(Map.get(args, :name))
      |> type(Map.get(args, :type))
      |> group(Map.get(args, :group))
      |> start_hm({Map.get(args, :start_hour), Map.get(args, :start_minute)})
      |> end_hm({Map.get(args, :end_hour), Map.get(args, :end_minute)})
      |> created_f(Map.get(args, :created_f))
      |> created_t(Map.get(args, :created_t))
  end

  def build(_) do
    {:error, "Невалидные данные для фильтра"}
  end

  defp filter do
    {:ok, %Core.Task.Types.Filter{}}
  end

  defp name({:ok, filter}, name) do
    with false <- name == nil,
         {:ok, filter} <- Name.build({:ok, filter}, name) do
      {:ok, filter}
    else
      true -> {:ok, filter}
      {:error, message} -> {:error, message}
    end
  end

  defp name({:error, message}, _) do
    {:error, message}
  end

  defp type({:ok, filter}, type) do
    with false <- type == nil,
         {:ok, filter} <- Type.build({:ok, filter}, type) do
      {:ok, filter}
    else
      true -> {:ok, filter}
      {:error, message} -> {:error, message}
    end
  end

  defp type({:error, message}, _) do
    {:error, message}
  end

  defp group({:ok, filter}, group) do
    with false <- group == nil,
         {:ok, _} <- Identifier.valid(group) do
      {:ok, Map.put(filter, :group, group)}
    else
      true -> {:ok, filter}
      {:error, message} -> {:error, message}
    end
  end

  defp group({:error, message}, _) do
    {:error, message}
  end

  defp created_f({:ok, filter}, created_f) do
    with false <- created_f == nil,
         {:ok, _} <- Date.valid(created_f) do
      {:ok, Map.put(filter, :created_f, created_f)}
    else
      true -> {:ok, filter}
      {:error, message} -> {:error, message}
    end
  end

  defp created_f({:error, message}, _) do
    {:error, message}
  end

  defp created_t({:ok, filter}, created_t) do
    with false <- created_t == nil,
         {:ok, _} <- Date.valid(created_t) do
      {:ok, Map.put(filter, :created_t, created_t)}
    else
      true -> {:ok, filter}
      {:error, message} -> {:error, message}
    end
  end

  defp created_t({:error, message}, _) do
    {:error, message}
  end

  defp start_hm({:ok, filter}, {start_hour, start_minute}) do
    with false <- start_hour == nil,
         false <- start_minute == nil,
         {:ok, filter} <- Start.build({:ok, filter}, {start_hour, start_minute}) do
      {:ok, filter}
    else
      true -> {:ok, filter}
      {:error, message} -> {:error, message}
    end
  end

  defp start_hm({:error, message}, _) do
    {:error, message}
  end

  defp end_hm({:ok, filter}, {end_hour, end_minute}) do
    with false <- end_hour == nil,
         false <- end_minute == nil,
         {:ok, filter} <- End.build({:ok, filter}, {end_hour, end_minute}) do
      {:ok, filter}
    else
      true -> {:ok, filter}
      {:error, message} -> {:error, message}
    end
  end

  defp end_hm({:error, message}, _) do
    {:error, message}
  end
end