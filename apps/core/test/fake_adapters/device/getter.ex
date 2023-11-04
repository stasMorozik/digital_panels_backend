defmodule FakeAdapters.Device.Getter do
  alias Core.Device.Ports.Getter
  alias Core.Device.Entity

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

  @behaviour Getter

  @impl Getter
  def get(id) when is_binary(id) do
    case :mnesia.transaction(fn ->
      :mnesia.match_object({
        :devices,
        :_,
        UUID.binary_to_string!(id),
        :_,
        :_,
        :_,
        :_,
        :_,
        :_,
        :_,
        :_,
        :_
      })
    end) do
      {:atomic, list_devices} ->
        if length(list_devices) > 0 do

          [device | _] = list_devices

          {
            :devices, 
            ssh_port,
            id,
            ssh_host,
            ssh_user,
            ssh_password,
            address,
            longitude,
            latitude,
            is_active,
            created,
            updated
          } = device

          Success.new(%Entity{
            id: id,
            ssh_port: ssh_port,
            ssh_host: ssh_host,
            ssh_user: ssh_user,
            ssh_password: ssh_password,
            address: address,
            longitude: longitude,
            latitude: latitude,
            is_active: is_active,
            created: created,
            updated: updated
          })

        else
          Error.new("Устройство не найдено")
        end
      {:aborted, _} ->  Error.new("Устройство не найдено")
    end
  end

  def get(_) do
    Error.new("Не валидный id")
  end
end
