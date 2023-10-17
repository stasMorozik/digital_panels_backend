defmodule Core.Device.Validators.Longitude do
  @moduledoc """
    Валидирует долготу устройства
  """

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

  @spec valid(float()) :: Success.t() | Error.t()
  def valid(longitude) when is_float(longitude) do
    with true <- longitude >= -180,
         true <- longitude <= 180 do
      Success.new(true)
    else
      false -> Error.new("Не валидная долгота")
    end
  end

  def valid(_) do
    Error.new("Не валидная долгота")
  end
end