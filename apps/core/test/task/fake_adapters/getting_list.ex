defmodule Task.FakeAdapters.GettingList do
  alias Core.Task.Ports.GetterList

  @behaviour GetterList

  alias Core.Task.Entity, as: TaskEntity
  alias Core.User.Entity, as: UserEntity

  alias Core.Shared.Types.Pagination
  alias Core.Task.Types.Filter
  alias Core.Task.Types.Sort

  @impl GetterList
  def get(%Pagination{} = _ , %Filter{} = filter, %Sort{} = _, %UserEntity{} = _) do
    case :mnesia.transaction (fn -> :mnesia.index_read(:tasks, filter.name, :name) end) do
      {:atomic, list_tasks} -> 
        case length(list_tasks) > 0 do
          false -> {:ok, []}
          true -> 
            [task | _] = list_tasks

            { :tasks, 
              id,
              hash,
              name,
              playlist,
              group,
              type,
              day,
              start_hour,
              end_hour,
              start_minute,
              end_minute,
              start_a,
              end_a,
              sum,
              created,
              updated
            } = task

            {:ok, [%TaskEntity{
              id: id,
              hash: hash,
              name: name,
              playlist: playlist,
              group: group,
              type: type,
              day: day,
              start_hour: start_hour,
              end_hour: end_hour,
              start_minute: start_minute,
              end_minute: end_minute,
              start: start_a,
              end: end_a,
              sum: sum,
              created: created,
              updated: updated
            }]}
        end
      {:aborted, _} -> {:ok, []}
    end
  end
end