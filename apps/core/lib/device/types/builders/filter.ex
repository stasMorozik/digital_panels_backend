defmodule Core.Device.Types.Builders.Filter do
  @moduledoc """

  """

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error
  alias Core.Device.Types.Filter

  @spec build(map()) :: Success.t() | Error.t()
  def build(%{
    is_active: is_active, 
    address:   address,
    ssh_host:  ssh_host, 
    created_f: created_f,
    created_t: created_t
  } = map) do
    type()
      |> is_nil(map, :ssh_port)
  end

  def build(_) do
    Error.new("Не валидные данные для фильтрации")
  end

  defp type do
    Success.new(%Filter{
      user_id: nil,
      is_active: nil, 
      address: nil, 
      ssh_host: nil, 
      created_f: nil,
      created_t: nil
    })
  end

  defp is_nil({:ok, entity}, map, key) do
    case Map.get(map, key) do
      nil -> {:nil, entity}
      _ -> { :ok, entity }
    end
  end

  defp date({:ok, type}, date) do
    
  end

  defp date({:nil, type}, _) do
    
  end

  defp date({:error, message}, _) do
    {:error, message}
  end

  defp is_active() do
    
  end

  defp is_active() do
    
  end
end