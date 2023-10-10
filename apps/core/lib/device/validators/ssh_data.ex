defmodule Core.Device.Validators.SshData do
  @moduledoc """
    Валидирует данные(хост, пользователь, пароль) для подключения по ssh к устройству
  """

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

  @spec valid(binary()) :: Success.t() | Error.t()
  def valid(data) when is_binary(data) do
    with true <- String.match?(data, ~r/^[a-zA-Z0-9\.\_\-]+$/),
         true <- String.length(data) >= 3,
         true <- String.length(data) <= 15 do
      Success.new(true)
    else
      false -> Error.new("Не валидные данные ssh соеденения")
    end
  end

  def valid(_) do
    Error.new("Не валидные данные ssh соеденения")
  end
end
