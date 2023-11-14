defmodule Core.Device.Validators.Address do
  @moduledoc """
    Валидирует адрес устройства
  """

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

  @min_length 10
  @max_length 256

  @spec valid(binary()) :: Success.t() | Error.t()
  def valid(address) when is_binary(address) do
    with true <- String.length(address) >= @min_length,
         true <- String.length(address) <= @max_length do
      Success.new(true)
    else
      false -> Error.new("Не валидный адрес")
    end
  end

  def valid(_) do
    Error.new("Не валидный адрес")
  end
end