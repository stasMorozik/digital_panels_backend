defmodule Core.Playlist.Builders.Filter do
  
  alias Core.Playlist.Validators.Name
  alias Core.Playlist.Validators.Sum
  alias Core.Shared.Validators.Date

  @spec build(map()) :: Core.Shared.Types.Success.t() | Core.Shared.Types.Error.t()
  def build(%{} = args) do
    filter()
      |> name(Map.get(args, :name))
      |> sum_f(Map.get(args, :sum_f))
      |> sum_t(Map.get(args, :sum_t))
      |> created_f(Map.get(args, :created_f))
      |> created_t(Map.get(args, :created_t))
  end

  def build(_) do
    {:error, "Невалидные данные для фильтра"}
  end

  defp filter do
    {:ok, %Core.Playlist.Types.Filter{}}
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
  
  defp sum_f({:ok, filter}, sum_f) do
    with false <- sum_f == nil,
         {:ok, _} <- Sum.valid(sum_f) do
      {:ok, Map.put(filter, :sum_f, sum_f)}
    else
      true -> {:ok, filter}
      {:error, message} -> {:error, message}
    end
  end

  defp sum_f({:error, message}, _) do
    {:error, message}
  end

  defp sum_t({:ok, filter}, sum_t) do
    with false <- sum_t == nil,
         {:ok, _} <- Sum.valid(sum_t) do
      {:ok, Map.put(filter, :sum_t, sum_t)}
    else
      true -> {:ok, filter}
      {:error, message} -> {:error, message}
    end
  end

  defp sum_t({:error, message}, _) do
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