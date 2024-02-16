defmodule Core.Assembly.Builders.Filter do
  
  alias Core.Assembly.Builders.Type

  alias Core.Shared.Validators.Date

  @spec build(map()) :: Core.Shared.Types.Success.t() | Core.Shared.Types.Error.t()
  def build(%{} = args) do
    filter()
      |> type(Map.get(args, :type))
      |> url(Map.get(args, :url))
      |> created_f(Map.get(args, :created_f))
      |> created_t(Map.get(args, :created_t))
  end

  def build(_) do
    {:error, "Невалидные данные для фильтра"}
  end

  defp filter do
    {:ok, %Core.Assembly.Types.Filter{}}
  end

  defp type({:ok, filter}, type) do
    case type do
      nil -> {:ok, filter}
      type -> Type.build({:ok, filter}, type)
    end
  end

  defp type({:error, message}, _) do
    {:error, message}
  end

  defp url({:ok, filter}, url) do
    with false <- url == nil,
         true <- is_binary(url) do
      {:ok, Map.put(filter, :url, url)}
    else
      true -> {:ok, filter}
      false -> {:error, "Не валидный url"}
    end
  end

  defp url({:error, message}, _) do
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