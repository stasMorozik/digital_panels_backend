defmodule Core.User.Validators.Name do
  @moduledoc """
    Валидирует имя фамилию пользователя
  """

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

  @format ~r/^[a-zA-ZйЙцЦуУкКеЕёЁнНгГшШщЩзЗхХъЪфФыЫвВаАпПрРоОлЛдДжЖэЭяЯчЧсСмМиИтТьЬбБюЮ]+$/
  @min_length 2
  @max_length 20

  @spec valid(binary()) :: Success.t() | Error.t()
  def valid(name) when is_binary(name) do
    with true <- String.match?(name, @format),
         true <- String.length(name) >= @min_length,
         true <- String.length(name) <= @max_length do
      Success.new(true)
    else
      false -> Error.new("Не валидное имя пользователя")
    end
  end

  def valid(_) do
    Error.new("Не валидное имя пользователя")
  end
end
