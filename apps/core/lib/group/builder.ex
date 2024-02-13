defmodule Core.Group.Builder do
  
  @moduledoc """
    Билдер сущности
  """

  alias Core.Group.Entity

  def build(%{name: name, devices: devices}) do
    entity() 
      |> Core.Group.Builders.Name.build(name)
      |> Core.Group.Builders.Devices.build(devices)
      |> Core.Group.Builders.Sum.build(devices)
      
  end

  def build(_) do
    {:error, "Не валидные данные для создания группы"}
  end

  defp entity do
    {:ok, %Entity{
      id: UUID.uuid4(), 
      created: Date.utc_today, 
      updated: Date.utc_today
    }}
  end
end