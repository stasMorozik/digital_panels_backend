defmodule Core.Task.Validators.Type do
  
  @types [
    "Каждый день",
    "Каждый день недели",
    "Каждый день месяца",
    "Определенное число"
  ]

  @spec valid(any()) :: Core.Shared.Types.Success.t() | Core.Shared.Types.Error.t()
  def valid(type) when is_binary(type) do
    case type in @types do
      false -> {:error, "Невалидный тип задания"}
      true -> {:ok, true}
    end
  end

  def valid(_) do
    {:error, "Невалидный тип задания"}
  end
end