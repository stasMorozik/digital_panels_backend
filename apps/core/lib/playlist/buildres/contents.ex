defmodule Core.Playlist.Builders.Contents do
  
  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

  @spec build(Success.t() | Error.t(), any()) :: Success.t() | Error.t()
  def build({:ok, entity}, contents) when is_list(contents) and length(contents) > 0 do
    case define(contents, {:ok, true}) do
      {:ok, true} -> {:ok, Map.put(entity, :contents, contents)}
      {:error, message} -> {:error, message}  
    end
  end

  def build({:ok, _}, _) do
    {:error, "Невалидные данные для построения плэйлиста"}
  end

  def build({:error, message}, _) do
    {:error, message}
  end

  defp define([%Core.Content.Entity{} = _head | tail], accumulator) do
    define(tail, accumulator)
  end

  defp define([_ | _tail], _) do
    {:error, "Невалидные данные для построения плэйлиста"}
  end

  defp define([], accumulator) do
    accumulator
  end
end