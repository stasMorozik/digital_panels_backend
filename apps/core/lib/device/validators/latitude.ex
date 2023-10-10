defmodule Core.Device.Validators.Latitude do
  @moduledoc """
    Валидирует широту устройства
  """

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

  @spec valid(float()) :: Success.t() | Error.t()
  def valid(latitude) when is_float(latitude) do
    with true <- latitude >= -90,
         true <- latitude <= 90 do
      Success.new(true)
    else
      false -> Error.new("Не валидная широта")
    end
  end

  def valid(_) do
    Error.new("Не валидная широта")
  end
end