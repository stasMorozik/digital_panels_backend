defmodule Core.Content.Validators.Name do
  @moduledoc """
    Валидирует название контента
  """

  @format ~r/^[a-zA-ZйЙцЦуУкКеЕёЁнНгГшШщЩзЗхХъЪфФыЫвВаАпПрРоОлЛдДжЖэЭяЯчЧсСмМиИтТьЬбБюЮ0-9\-\_]+$/
  @min_length 2
  @max_length 20

  @spec valid(any()) :: Core.Shared.Types.Success.t() | Core.Shared.Types.Error.t()
  def valid(name) when is_binary(name) do
    with true <- String.match?(name, @format),
         true <- String.length(name) >= @min_length,
         true <- String.length(name) <= @max_length do
      {:ok, true}
    else
      false -> {:error, "Невалидное название контента"}
    end
  end

  def valid(_) do
    {:error, "Невалидное название контента"}
  end
end
