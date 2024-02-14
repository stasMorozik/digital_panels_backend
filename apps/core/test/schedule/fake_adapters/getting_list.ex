defmodule Schedule.FakeAdapters.GettingList do
  alias Core.Schedule.Ports.GetterList

  @behaviour GetterList

  alias Core.Schedule.Entity, as: ScheduleEntity
  alias Core.User.Entity, as: UserEntity

  alias Core.Shared.Types.Pagination
  alias Core.Schedule.Types.Filter
  alias Core.Schedule.Types.Sort

  @impl GetterList
  def get(%Pagination{} = _ , %Filter{} = filter, %Sort{} = _, %UserEntity{} = _) do
    case :mnesia.transaction (fn -> :mnesia.index_read(:schedules, filter.name, :name) end) do
      {:atomic, list_schedules} -> 
        case length(list_schedules) > 0 do
          false -> {:ok, []}
          true -> 
            [schedule | _] = list_schedules

            {:schedules, id, name, timings, group, created, updated} = schedule

            {:ok, [%ScheduleEntity{
              id: id,
              name: name,
              timings: timings,
              group: group,
              created: created,
              updated: updated
            }]}
        end
      {:aborted, _} -> {:ok, []}
    end
  end
end