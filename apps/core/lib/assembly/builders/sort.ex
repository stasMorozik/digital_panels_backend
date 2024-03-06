defmodule Core.Assembly.Builders.Sort do
  
  alias Core.Shared.Validators.Sort

  @spec build(map()) :: Core.Shared.Types.Success.t() | Core.Shared.Types.Error.t()
  def build(%{} = args) do
    sort()
      |> type(Map.get(args, :type))
      |> created(Map.get(args, :created))
  end

  def build(_) do
    {:error, "Невалидные данные для сортировки"}
  end

  defp sort do
    {:ok, %Core.Assembly.Types.Sort{}}
  end

  defp type({:ok, sort}, order) do
    with false <- order == nil,
         {:ok, _} <- Sort.valid(order) do
      {:ok, Map.put(sort, :type, String.upcase(order))}
    else
      true -> {:ok, sort}
    end
  end

  defp type({:error, message}, _) do
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