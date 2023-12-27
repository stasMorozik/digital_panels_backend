defmodule Device.FakeAdapters.Getting do
  alias Core.Device.Ports.Getter

  @behaviour Getter

  alias Core.Device.Entity, as: DeviceEntity
  alias Core.User.Entity, as: UserEntity

  @impl Getter
  def get(id, %UserEntity{} = _) do
    case :mnesia.transaction (fn -> :mnesia.read({:devices, UUID.binary_to_string!(id)}) end) do
      {:atomic, list_devices} -> 
        case length(list_devices) > 0 do
          false -> {:error, "Устройство не найдено"}
          true -> 
            [device | _] = list_devices

            {:devices, id, ip, latitude, longitude, created, updated} = device

            {:ok, %DeviceEntity{
              id: id,
              ip: ip,
              latitude: latitude,
              longitude: longitude,
              created: created,
              updated: updated
            }}
        end
      {:aborted, _} -> {:error, "Устройство не найдено"}
    end
  end
end