defmodule Core.Playlist.Validators.Contents do
  @moduledoc """
    Валидирует список контента
  """

  @spec valid(any()) :: Core.Shared.Types.Success.t() | Core.Shared.Types.Error.t()
  def valid(contents) when is_list(contents) and length(contents) > 0 do
    valid(contents, {:ok, true})
  end

  def valid(_) do
    {:error, "Невалидный список конента"}
  end

  defp valid([%Core.Content.Entity{} = _head | tail], acc) do
    valid(tail, acc)
  end

  defp valid([], acc) do
    acc
  end

  defp valid([_ | _tail], _) do
    {:error, "Невалидный список конента"}
  end
end