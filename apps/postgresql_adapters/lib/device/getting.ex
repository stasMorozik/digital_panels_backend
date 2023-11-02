defmodule PostgresqlAdapters.Device.Getting do
  alias Core.Device.Ports.Getter
  alias Core.Device.Entity

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error
  alias Core.Shared.Types.Exception

  @behaviour Getter

  @impl Getter
  def get(id) when is_binary(id) do
    case :ets.lookup(:connections, "postgresql") do
      [{"postgresql", "", connection}] ->

        with query <- "SELECT 
                id, address, 
                ssh_host, ssh_port, ssh_user, ssh_password,
                is_active, longitude, latitude, 
                created, updated
               FROM devices WHERE id = $1",
             {:ok, q} <- Postgrex.prepare(connection, "", query),
             {:ok, _, result} <- Postgrex.execute(connection, q, [id]),
             true <- result.num_rows > 0,
             [[
                id, address, 
                ssh_host, ssh_port, ssh_user, ssh_password,
                is_active, longitude, latitude, 
                created, updated
             ]] <- result.rows,
             device_entity <- mapper([
                id, address, 
                ssh_host, ssh_port, ssh_user, ssh_password,
                is_active, longitude, latitude, 
                created, updated
             ]) do

          Success.new(device_entity)
          
        else
          false -> Error.new("Плэйлист не найден")
          {:error, e} -> Exception.new(e.message)
        end

      [] -> Exception.new("Database connection error")
      _ -> Exception.new("Database connection error")
    end
  end

  def get(_) do
    Error.new("Не валидные данные для получения пользователя")
  end

  defp mapper([
    id, address, 
    ssh_host, ssh_port, ssh_user, ssh_password,
    is_active, longitude, latitude, 
    created, updated
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
