defmodule FakeAdapters.Device.GetterList do
  alias Core.Device.Ports.GetterList
  alias Core.Device.Entity

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

  alias Core.Device.Types.Filter
  alias Core.Device.Types.Sort
  alias Core.Shared.Types.Pagination

  @behaviour GetterList

  @impl GetterList
  def get(%Filter{
    user_id: _,
    is_active: _, 
    address: _, 
    ssh_host: ssh_host, 
    created_f: _,
    created_t: _,
    updated_f: _,
    updated_t: _,
  }, %Sort{
    is_active: _,
    created: _,
    updated: _
  }, %Pagination{
    page: _,
    limit: _
  }) do
    case :mnesia.transaction(fn -> 
      :mnesia.index_read(:devices, ssh_host, :ssh_host) 
    end) do
      {:atomic, list_devices} ->
        if length(list_devices) > 0 do

          [device | _] = list_devices

          {
            :devices, 
            id,
            _,
            _,
            ssh_port,
            ssh_host,
            ssh_user,
            ssh_password,
            address,
            longitude,
            latitude,
            created,
            updated
          } = device

          Success.new([%Entity{
            id: id,
            ssh_port: ssh_port,
            ssh_host: ssh_host,
            ssh_user: ssh_user,
            ssh_password: ssh_password,
            address: address,
            longitude: longitude,
            latitude: latitude,
            created: created,
            updated: updated
          }])

        else
          Error.new("Устройства не найдены")
        end
      {:aborted, _} ->  Error.new("Устройства не найдены")
    end
  end

  def get(_, _, _) do
    Error.new("Не валидный id")
  end
end
