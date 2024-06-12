defmodule Core.Group.Builder do
  @moduledoc """
    Билдер сущности
  """

  alias Core.Group.Entity

  alias Core.Shared.Builders.BuilderProperties
  alias Core.Group.Validators.Name

  def build(%{name: name}) do
    setter = fn (
      entity, 
      key, 
      value
    ) -> 
      Map.put(entity, key, value) 
    end

    entity() 
      |> BuilderProperties.build(Name, setter, :name, name)
      
  end

  def build(_) do
    {:error, "Не валидные данные для создания группы"}
  end

  defp entity do
    {:ok, %Entity{
      id: UUID.uuid4(),
      sum: 0, 
      created: Date.utc_today, 
      updated: Date.utc_today
    }}
  end
end