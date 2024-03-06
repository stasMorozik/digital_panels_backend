defmodule Group.FakeAdapters.GettingList do
  alias Core.Group.Ports.GetterList

  @behaviour GetterList

  alias Core.Group.Entity, as: GroupEntity
  alias Core.User.Entity, as: UserEntity

  alias Core.Shared.Types.Pagination
  alias Core.Group.Types.Filter
  alias Core.Group.Types.Sort

  @impl GetterList
  def get(%Pagination{} = _ , %Filter{} = filter, %Sort{} = _, %UserEntity{} = _) do
    case :mnesia.transaction (fn -> :mnesia.index_read(:groups, filter.name, :name) end) do
      {:atomic, list_groups} -> 
        case length(list_groups) > 0 do
          false -> {:ok, []}
          true -> 
            [group | _] = list_groups

            {:groups, id, name, sum, devices, created, updated} = group

            {:ok, [%GroupEntity{
              id: id,
              name: name,
              sum: sum,
              devices: devices,
              created: created,
              updated: updated
            }]}
        end
      {:aborted, _} -> {:ok, []}
    end
  end
end