defmodule Group.FakeAdapters.Getting do
  alias Core.Group.Ports.Getter

  @behaviour Getter

  alias Core.Group.Entity, as: GroupEntity
  alias Core.User.Entity, as: UserEntity

  @impl Getter
  def get(id, %UserEntity{} = _) do
    case :mnesia.transaction (fn -> :mnesia.read({:groups, UUID.binary_to_string!(id)}) end) do
      {:atomic, list_groups} -> 
        case length(list_groups) > 0 do
          false -> {:error, "Группа не найдена"}
          true -> 
            [group | _] = list_groups

            {:groups, id, name, sum, devices, created, updated} = group

            {:ok, %GroupEntity{
              id: id,
              name: name,
              sum: sum,
              devices: devices,
              created: created,
              updated: updated
            }}
        end
      {:aborted, _} -> {:error, "Группа не найдена"}
    end
  end
end