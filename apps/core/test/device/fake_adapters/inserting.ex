defmodule Device.FakeAdapters.Inserting do
  alias Core.Device.Ports.Transformer

  @behaviour Transformer

  alias Core.Device.Entity, as: DeviceEntity
  alias Core.User.Entity, as: UserEntity

  @impl Transformer
  def transform(%DeviceEntity{} = device, %UserEntity{} = _) do
    case :mnesia.transaction(
      fn -> :mnesia.write({
        :devices, 
        device.id, 
        device.ip, 
        device.latitude, 
        device.longitude, 
        device.created, 
        device.updated
      }) end
    ) do
      {:atomic, :ok} -> {:ok, true}
      {:aborted, _} -> {:error, "Устройство уже существует"}
    end
  end
end