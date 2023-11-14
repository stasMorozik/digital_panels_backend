defmodule Core.Device.Validators.SshData do
  @moduledoc """
    Валидирует данные(хост, пользователь, пароль) для подключения по ssh к устройству
  """

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

  @format ~r/^[a-zA-Z0-9\.\_\-]+$/
  @min_length 3
  @max_length 15

  @spec valid(binary()) :: Success.t() | Error.t()
  def valid(data) when is_binary(data) do
    with true <- String.length(data) >= @min_length,
         true <- String.length(data) <= @max_length,
         true <- String.match?(data, @format) do
      Success.new(true)
    else
      false -> Error.new("Не валидные данные ssh соеденения")
    end
  end

  def valid(_) do
    Error.new("Не валидные данные ssh соеденения")
  end
end
