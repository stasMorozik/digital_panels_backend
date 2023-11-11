defmodule Core.Device.Validators.SshPort do
  @moduledoc """
    Валидирует порт ssh для устройства
  """

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

  @min 22
  @max 65535

  @spec valid(integer()) :: Success.t() | Error.t()
  def valid(port) when is_integer(port) do
    with true <- port >= @min,
         true <- port <= @max do
      Success.new(true)
    else
      false -> Error.new("Не валидный порт")
    end
  end

  def valid(_) do
    Error.new("Не валидный порт")
  end
end