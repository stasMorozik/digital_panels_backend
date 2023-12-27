defmodule Core.Device.Validators.Ip do
  @moduledoc """
    Валидирует ip устройства
  """

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

  @format ~r/^((?:[0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])[.]){3}(?:[0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])$/

  @spec valid(any()) :: Success.t() | Error.t()
  def valid(ip) when is_binary(ip) do
    case String.match?(ip, @format) do
      true -> {:ok, true}
      false -> {:error, "Невалидный ip адрес"}
    end
  end

  def valid(_) do
    {:error, "Невалидный ip адрес"}
  end
end