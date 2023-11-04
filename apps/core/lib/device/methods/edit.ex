defmodule Core.Device.Methods.Edit do
  @moduledoc """
    Изменяет поля сущности
  """
  alias Core.Device.Entity
  
  alias Core.Device.Validators.Latitude
  alias Core.Device.Validators.Longitude
  alias Core.Device.Validators.SshData
  alias Core.Device.Validators.SshPort

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

  @spec edit(Entity.t(), map()) :: Success.t() | Error.t()
  def edit(%Entity{
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
  },%{
    ssh_port: new_ssh_port,
    ssh_host: new_ssh_host,
    ssh_user: new_ssh_user,
    ssh_password: new_ssh_password,
    address: new_address,
    longitude: new_longitude,
    latitude: new_latitude,
    is_active: new_is_active
  }) do
    entity = %Entity{
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
    }

    map = %{
      ssh_port: new_ssh_port,
      ssh_host: new_ssh_host,
      ssh_user: new_ssh_user,
      ssh_password: new_ssh_password,
      address: new_address,
      longitude: new_longitude,
      latitude: new_latitude,
      is_active: new_is_active,
    }

    updated(entity)
      |> is_nil(map, :ssh_port)
      |> ssh_port(new_ssh_port)
      |> is_nil(map, :ssh_host)
      |> ssh_host(new_ssh_host)
      |> is_nil(map, :ssh_user)
      |> ssh_user(new_ssh_user)
      |> is_nil(map, :ssh_password)
      |> ssh_password(new_ssh_password)
      |> is_nil(map, :longitude)
      |> longitude(new_longitude)
      |> is_nil(map, :latitude)
      |> latitude(new_latitude)
      |> is_nil(map, :address)
      |> address(new_address)
      |> is_nil(map, :is_active)
      |> is_active(new_is_active)
  end

  def edit(_, _) do
    Error.new("Не валидные данные для редактирования устройства")
  end

  defp updated(entity) do
    Success.new(Map.put(entity, :updated, Date.utc_today))
  end

  defp is_nil({:ok, entity}, map, key) do
    case Map.get(map, key) do
      nil -> {:nil, entity}
      _ -> { :ok, entity }
    end
  end

  defp is_nil({ :error, entity }, _, _) do
    { :error, entity }
  end

  # Функция построения ssh порта
  defp ssh_port({:ok, entity}, new_ssh_port) do
    case SshPort.valid(new_ssh_port) do
      {:ok, _} -> Success.new(Map.put(entity, :ssh_port, new_ssh_port))
      {:error, error} -> {:error, error}
    end
  end

  defp ssh_port({:nil, entity}, _) do
    {:ok, entity}
  end

  defp ssh_port({:error, message}, _) do
    {:error, message}
  end

  # Функция построения ssh хоста
  defp ssh_host({:ok, entity}, new_ssh_host) do
    case SshData.valid(new_ssh_host) do
      {:ok, _} -> Success.new(Map.put(entity, :ssh_host, new_ssh_host))
      {:error, error} -> {:error, error}
    end
  end

  defp ssh_host({:nil, entity}, _) do
    {:ok, entity}
  end

  defp ssh_host({:error, message}, _) do
    {:error, message}
  end

  # Функция построения пользователя ssh
  defp ssh_user({:ok, entity}, new_ssh_user) do
    case SshData.valid(new_ssh_user) do
      {:ok, _} -> Success.new(Map.put(entity, :ssh_user, new_ssh_user))
      {:error, error} -> {:error, error}
    end
  end

  defp ssh_user({:nil, entity}, _) do
    {:ok, entity}
  end

  defp ssh_user({:error, message}, _) do
    {:error, message}
  end

  # Функция построения пароля ssh
  defp ssh_password({:ok, entity}, new_ssh_password) do
    case SshData.valid(new_ssh_password) do
      {:ok, _} -> Success.new(Map.put(entity, :ssh_password, new_ssh_password))
      {:error, error} -> {:error, error}
    end
  end

  defp ssh_password({:nil, entity}, _) do
    {:ok, entity}
  end

  defp ssh_password({:error, message}, _) do
    {:error, message}
  end

  # Функция построения долготы
  defp longitude({:ok, entity}, new_longitude) do
    case Longitude.valid(new_longitude) do
      {:ok, _} -> Success.new(Map.put(entity, :longitude, new_longitude))
      {:error, error} -> {:error, error}
    end
  end

  defp longitude({:nil, entity}, _) do
    {:ok, entity}
  end

  defp longitude({:error, message}, _) do
    {:error, message}
  end

  # Функция построения широты
  defp latitude({:ok, entity}, new_latitude) do
    case Latitude.valid(new_latitude) do
      {:ok, _} -> Success.new(Map.put(entity, :latitude, new_latitude))
      {:error, error} -> {:error, error}
    end
  end

  defp latitude({:nil, entity}, _) do
    {:ok, entity}
  end

  defp latitude({:error, message}, _) do
    {:error, message}
  end

  # Функция построения адреса
  defp address({:ok, entity}, new_address) when is_binary(new_address) do
    Success.new(Map.put(entity, :address, new_address))
  end

  defp address({:ok, _}, _) do
    Error.new("Не валидный адрес")
  end

  defp address({:nil, entity}, _) do
    {:ok, entity}
  end

  defp address({:error, message}, _) do
    {:error, message}
  end

  # Функция построения активности
  defp is_active({:ok, entity}, new_is_active) when is_boolean(new_is_active) do
    Success.new(Map.put(entity, :is_active, new_is_active))
  end

  defp is_active({:ok, entity}, _) do
    Error.new("Не валидная активность")
  end

  defp is_active({:nil, entity}, _) do
    {:ok, entity}
  end

  defp is_active({:error, message}, _) do
    {:error, message}
  end
end