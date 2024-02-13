defmodule Core.Content.Builders.Filter do
  
  alias Core.Content.Validators.Name
  alias Core.Content.Validators.Duration
  alias Core.Shared.Validators.Date

  alias UUID

  @spec build(map()) :: Core.Shared.Types.Success.t() | Core.Shared.Types.Error.t()
  def build(%{} = args) do
    filter()
      |> name(Map.get(args, :name))
      |> duration(Map.get(args, :duration))
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

  defp duration({:ok, filter}, duration) do
    with false <- duration == nil,
         {:ok, _} <- Duration.valid(duration) do
      {:ok, Map.put(filter, :duration, duration)}
    else
      true -> {:ok, filter}
      {:error, message} -> {:error, message}
    end
  end

  defp duration({:error, message}, _) do
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