defmodule Device.FakeAdapters.GettingList do
  alias Core.Device.Ports.GetterList

  @behaviour GetterList

  alias Core.Device.Entity, as: DeviceEntity
  alias Core.User.Entity, as: UserEntity

  alias Core.Shared.Types.Pagination
  alias Core.Device.Types.Filter
  alias Core.Device.Types.Sort

  @impl GetterList
  def get(%Pagination{} = _ , %Filter{} = filter, %Sort{} = _, %UserEntity{} = _) do
    case :mnesia.transaction (fn -> :mnesia.index_read(:devices, filter.ip, :ip) end) do
      {:atomic, list_devices} -> 
        case length(list_devices) > 0 do
          false -> {:ok, []}
          true -> 
            [device | _] = list_devices

            {:devices, id, ip, latitude, longitude, created, updated} = device

            {:ok, [%DeviceEntity{
              id: id,
              ip: ip,
              latitude: latitude,
              longitude: longitude,
              created: created,
              updated: updated
            }]}
        end
      {:aborted, _} -> {:ok, []}
    end
  end
end