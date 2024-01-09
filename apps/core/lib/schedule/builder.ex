defmodule Core.Schedule.Builder do
  @moduledoc """
    Билдер сущности
  """

  alias UUID

  @spec build(map()) :: Core.Shared.Types.Success.t() | Core.Shared.Types.Error.t()
  def build(%{timings: timings, group: group}) do
    entity()
      |> Core.Schedule.Builders.Timings.build(timings)
      |> Core.Schedule.Builders.Group.build(group)
  end

  def build(_) do
    {:error, "Невалидные данные для построения расписания"}
  end

  # Функция построения базового расписания
  defp entity do
    {:ok, %Core.Schedule.Entity{
      id: UUID.uuid4(), 
      created: Date.utc_today, 
      updated: Date.utc_today
    }}
  end
end