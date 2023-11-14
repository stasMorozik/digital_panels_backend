defmodule Core.Device.Types.Builders.Filter do
  @moduledoc """

  """

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

  @spec build(map()) :: Success.t() | Error.t()
  def build(%{
    
  }) when is_map(map) do
    
  end

  def build(_) do
    Error.new("Не валидные данные для фильтрации")
  end

  defp is_nil({:ok, entity}, map, key) do
    case Map.get(map, key) do
      nil -> {:nil, entity}
      _ -> { :ok, entity }
    end
  end

  defp created do
    
  end

  defp is_active do
    
  end
end