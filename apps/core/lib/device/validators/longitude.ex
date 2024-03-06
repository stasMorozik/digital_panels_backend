defmodule Core.Device.Validators.Longitude do
  @moduledoc """
    Валидирует долготу устройства
  """

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

  @min -180
  @max 180

  @spec valid(any()) :: Success.t() | Error.t()
  def valid(longitude) when is_float(longitude) do
    with true <- longitude >= @min,
         true <- longitude <= @max do
      {:ok, true}
    else
      false -> {:error, "Невалидная долгота"}
    end
  end

  def valid(_) do
    {:error, "Невалидная долгота"}
  end
end