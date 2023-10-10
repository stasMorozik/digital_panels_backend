defmodule Core.User.Validators.Name do
  @moduledoc """
    Валидирует имя фамилию пользователя
  """

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

  @spec valid(binary()) :: Success.t() | Error.t()
  def valid(name) when is_binary(name) do
    with true <- String.match?(name, ~r/^[a-zA-ZйЙцЦуУкКеЕёЁнНгГшШщЩзЗхХъЪфФыЫвВаАпПрРоОлЛдДжЖэЭяЯчЧсСмМиИтТьЬбБюЮ]+$/),
         true <- String.length(name) >= 2 do
      Success.new(true)
    else
      false -> Error.new("Не валидное имя пользователя")
    end
  end

  def valid(_) do
    Error.new("Не валидное имя пользователя")
  end
end
