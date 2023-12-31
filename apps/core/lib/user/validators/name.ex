defmodule Core.User.Validators.Name do
  @moduledoc """
    Валидирует имя фамилию пользователя
  """

  @format ~r/^[a-zA-ZйЙцЦуУкКеЕёЁнНгГшШщЩзЗхХъЪфФыЫвВаАпПрРоОлЛдДжЖэЭяЯчЧсСмМиИтТьЬбБюЮ]+$/
  @min_length 2
  @max_length 20

  @spec valid(any()) :: Core.Shared.Types.Success.t() | Core.Shared.Types.Error.t()
  def valid(name) when is_binary(name) do
    with true <- String.match?(name, @format),
         true <- String.length(name) >= @min_length,
         true <- String.length(name) <= @max_length do
      {:ok, true}
    else
      false -> {:error, "Невалидное имя пользователя"}
    end
  end

  def valid(_) do
    {:error, "Невалидное имя пользователя"}
  end
end
