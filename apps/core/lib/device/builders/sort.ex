defmodule Core.Device.Builders.Sort do

  alias Core.Shared.Validators.Sort

  @spec build(map()) :: Core.Shared.Types.Success.t() | Core.Shared.Types.Error.t()
  def build(%{} = args) do
    sort()
      |> ip(Map.get(args, :ip))
      |> latitude(Map.get(args, :latitude))
      |> longitude(Map.get(args, :longitude))
      |> is_active(Map.get(args, :is_active))
      |> created(Map.get(args, :created))
  end

  def build(_) do
    {:error, "Невалидные данные для сортировки"}
  end

  defp sort do
    {:ok, %Core.Device.Types.Sort{}}
  end

  defp ip({:ok, sort}, order) do
    with false <- order == nil,
         {:ok, _} <- Sort.valid(order) do
      {:ok, Map.put(sort, :ip, String.upcase(order))}
    else
      true -> {:ok, sort}
    end
  end

  defp ip({:error, message}, _) do
    {:error, message}
  end

  defp latitude({:ok, sort}, order) do
    with false <- order == nil,
         {:ok, _} <- Sort.valid(order) do
      {:ok, Map.put(sort, :latitude, String.upcase(order))}
    else
      true -> {:ok, sort}
    end
  end

  defp latitude({:error, message}, _) do
    {:error, message}
  end

  defp longitude({:ok, sort}, order) do
    with false <- order == nil,
         {:ok, _} <- Sort.valid(order) do
      {:ok, Map.put(sort, :longitude, String.upcase(order))}
    else
      true -> {:ok, sort}
    end
  end

  defp longitude({:error, message}, _) do
    {:error, message}
  end

  defp is_active({:ok, sort}, order) do
    with false <- order == nil,
         {:ok, _} <- Sort.valid(order) do
      {:ok, Map.put(sort, :is_active, String.upcase(order))}
    else
      true -> {:ok, sort}
    end
  end

  defp is_active({:error, message}, _) do
    {:error, message}
  end

  defp created({:ok, sort}, order) do
    with false <- order == nil,
         {:ok, _} <- Sort.valid(order) do
      {:ok, Map.put(sort, :created, String.upcase(order))}
    else
      true -> {:ok, sort}
    end
  end

  defp created({:error, message}, _) do
    {:error, message}
  end
end