defmodule Core.Assembly.Validators.Type do
  @moduledoc """
    Валидирует тип сборки(для windows или для linux)
  """

  @types [
    "Windows",
    "Linux"
  ]

  @spec valid(any()) :: Core.Shared.Types.Success.t() | Core.Shared.Types.Error.t()
  def valid(type) when is_binary(type) do
    case type in @types do
      false -> {:error, "Невалидный тип сборки"}
      true -> {:ok, true}
    end
  end

  def valid(_) do
    {:error, "Невалидная группа"}
  end
end