defmodule Core.Playlist.Validators.Name do
  @moduledoc """
    Валидирует название плэйлиста
  """

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

  @format ~r/^[а-яА-ЯёЁa-zA-Z0-9\.\_\-]+$/
  @min_length 3
  @max_length 64

  @spec valid(binary()) :: Success.t() | Error.t()
  def valid(name) when is_binary(name) do
    with true <- String.length(name) >= @min_length,
         true <- String.length(name) <= @max_length,
				 true <- String.match?(name, @format) do
      Success.new(true)
    else
      false -> Error.new("Не валидное название плэйлиста")
    end
  end

  def valid(_) do
    Error.new("Не валидное название плэйлиста")
  end
end
