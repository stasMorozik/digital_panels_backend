defmodule Core.Schedule.Validators.Type do
  
  @types %{
    "Каждый день": true,
    "Каждый день недели": true,
    "Каждый день месяца": true,
    "Определенное число": true
  }

  @spec valid(any()) :: Core.Shared.Types.Success.t() | Core.Shared.Types.Error.t()
  def valid(type) when is_binary(type) do
    case Map.get(@types, String.to_atom(type)) do
      nil -> {:error, "Невалидный тип тайминга"}
      _ -> {:ok, true}
    end
  end

  def valid(_) do
    {:error, "Невалидный тип тайминга"}
  end
end