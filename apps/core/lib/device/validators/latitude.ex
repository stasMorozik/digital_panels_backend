defmodule Core.Device.Validators.Latitude do
  @moduledoc """
    Валидирует широту устройства
  """

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

  @min -90
  @max 90

  @spec valid(any()) :: Success.t() | Error.t()
  def valid(latitude) when is_float(latitude) do
    with true <- latitude >= @min,
         true <- latitude <= @max do
      {:ok, true}
    else
      false -> {:error, "Невалидная широта"}
    end
  end

  def valid(_) do
    {:error, "Невалидная широта"}
  end
end