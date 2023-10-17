defmodule Core.Device.Validators.SshPort do
  @moduledoc """
    Валидирует порт ssh для устройства
  """

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

  @spec valid(integer()) :: Success.t() | Error.t()
  def valid(port) when is_integer(port) do
    with true <- port >= 22,
         true <- port <= 65535 do
      Success.new(true)
    else
      false -> Error.new("Не валидный порт")
    end
  end

  def valid(_) do
    Error.new("Не валидный порт")
  end
end