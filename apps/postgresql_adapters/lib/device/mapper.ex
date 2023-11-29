defmodule PostgresqlAdapters.Device.Mapper do
  alias Core.Device.Entity
  
  def to_entity([
    id, 
    address, 
    ssh_host, 
    ssh_port, 
    ssh_user, 
    ssh_password,
    is_active, 
    longitude, 
    latitude, 
    created, 
    updated
  ]) do
    %Entity{
      id: UUID.binary_to_string!(id),
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
    }
  end
end