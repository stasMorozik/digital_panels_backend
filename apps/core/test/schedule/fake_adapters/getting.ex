defmodule Schedule.FakeAdapters.Getting do
  alias Core.Schedule.Ports.Getter

  @behaviour Getter

  alias Core.Schedule.Entity, as: ScheduleEntity
  alias Core.User.Entity, as: UserEntity

  @impl Getter
  def get(id, %UserEntity{} = _) do
    case :mnesia.transaction (fn -> :mnesia.read({:schedules, UUID.binary_to_string!(id)}) end) do
      {:atomic, list_schedules} -> 
        case length(list_schedules) > 0 do
          false -> {:error, "Расписание не найдено"}
          true -> 
            [schedule | _] = list_schedules

            {:schedules, id, name, timings, group, created, updated} = schedule

            {:ok, %ScheduleEntity{
              id: id,
              name: name,
              timings: timings,
              group: group,
              created: created,
              updated: updated
            }}
        end
      {:aborted, _} -> {:error, "Расписание не найдено"}
    end
  end
end