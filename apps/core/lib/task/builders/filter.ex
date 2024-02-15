defmodule Core.Task.Builders.Filter do
  
  alias Core.Task.Validators.Name
  alias Core.Task.Validators.Type
  alias Core.Shared.Validators.Date
  alias Core.Shared.Validators.Identifier

  @spec build(map()) :: Core.Shared.Types.Success.t() | Core.Shared.Types.Error.t()
  def build(%{} = args) do
    filter()
      |> name(Map.get(args, :name))
      |> type(Map.get(args, :type))
      |> group(Map.get(args, :group))
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
         {:ok, _} <- Name.valid(name) do
      {:ok, Map.put(filter, :name, name)}
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
         {:ok, _} <- Type.valid(type) do
      {:ok, Map.put(filter, :type, type)}
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
end