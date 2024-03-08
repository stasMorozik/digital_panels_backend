defmodule Core.Content.Builders.Filter do
  
  alias Core.Content.Builders.Name
  alias Core.Shared.Validators.Date

  alias UUID

  @spec build(map()) :: Core.Shared.Types.Success.t() | Core.Shared.Types.Error.t()
  def build(%{} = args) do
    filter()
      |> name(Map.get(args, :name))
      |> duration_f(Map.get(args, :duration_f))
      |> duration_t(Map.get(args, :duration_t))
      |> created_f(Map.get(args, :created_f))
      |> created_t(Map.get(args, :created_t))
  end

  def build(_) do
    {:error, "Невалидные данные для фильтра"}
  end

  defp filter do
    {:ok, %Core.Content.Types.Filter{}}
  end

  defp name({:ok, filter}, name) do
    case name do
      nil -> {:ok, filter}
      name -> Name.build({:ok, filter}, name)
    end
  end

  defp name({:error, message}, _) do
    {:error, message}
  end

  defp duration_f({:ok, filter}, duration_f) do
    with false <- duration_f == nil,
         {:ok, _} <- Core.Content.Validators.Duration.valid(duration_f) do
      {:ok, Map.put(filter, :duration_f, duration_f)}
    else
      true -> {:ok, filter}
      {:error, message} -> {:error, message}
    end
  end

  defp duration_f({:error, message}, _) do
    {:error, message}
  end

  defp duration_t({:ok, filter}, duration_t) do
    with false <- duration_t == nil,
         {:ok, _} <- Core.Content.Validators.Duration.valid(duration_t) do
      {:ok, Map.put(filter, :duration_t, duration_t)}
    else
      true -> {:ok, filter}
      {:error, message} -> {:error, message}
    end
  end

  defp duration_t({:error, message}, _) do
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