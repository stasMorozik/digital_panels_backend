defmodule Core.Group.Validators.Devices do
  @moduledoc """
    Валидирует список устройств
  """

  @spec valid(any()) :: Core.Shared.Types.Success.t() | Core.Shared.Types.Error.t()
  def valid(devices) when is_list(devices) and length(devices) > 0 do
    valid(devices, {:ok, true})
  end

  def valid(_) do
    {:error, "Невалидный список устройств"}
  end

  defp valid([%Core.Device.Entity{} = _head | tail], acc) do
    valid(tail, acc)
  end

  defp valid([], acc) do
    acc
  end

  defp valid([_ | _tail], _) do
    {:error, "Невалидный список устройств"}
  end
end