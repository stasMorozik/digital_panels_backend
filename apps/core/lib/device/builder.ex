defmodule Core.Device.Builder do
  @moduledoc """
    Билдер сущности
  """

  alias UUID
  alias Core.Device.Entity
  alias Core.Device.Validators.Latitude
  alias Core.Device.Validators.Longitude
  alias Core.Device.Validators.SshData
  alias Core.Device.Validators.SshPort

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

  @spec build(map()) :: Success.t() | Error.t()
  def build(%{
    ssh_port: ssh_port,
    ssh_host: ssh_host,
    ssh_user: ssh_user,
    ssh_password: ssh_password,
    address: address,
    longitude: longitude,
    latitude: latitude
  }) do
    entity()
      |> ssh_port(ssh_port)
      |> ssh_host(ssh_host)
      |> ssh_user(ssh_user)
      |> ssh_password(ssh_password)
      |> longitude(longitude)
      |> latitude(latitude)
      |> address(address)
  end

  def build(_) do
    Error.new("Не валидные данные для построения устройства")
  end

   # Функция построения базового устройства
  defp entity do
    Success.new(%Entity{
      id: UUID.uuid4(),
      created: Date.utc_today,
      updated: Date.utc_today,
      is_active: false
    })
  end

  # Функция построения ssh порта
  defp ssh_port({ :ok, entity }, new_ssh_port) do
    case SshPort.valid(new_ssh_port) do
      {:ok, _} -> Success.new(Map.put(entity, :ssh_port, new_ssh_port))
      {:error, error} -> {:error, error}
    end
  end

  defp ssh_port({:error, message}, _) do
    Error.new(message)
  end

  # Функция построения ssh хоста
  defp ssh_host({ :ok, entity }, new_ssh_host) do
    case SshData.valid(new_ssh_host) do
      {:ok, _} -> Success.new(Map.put(entity, :ssh_host, new_ssh_host))
      {:error, error} -> {:error, error}
    end
  end

  defp ssh_host({:error, message}, _) do
    Error.new(message)
  end

  # Функция построения пользователя ssh
  defp ssh_user({ :ok, entity }, new_ssh_user) do
    case SshData.valid(new_ssh_user) do
      {:ok, _} -> Success.new(Map.put(entity, :ssh_user, new_ssh_user))
      {:error, error} -> {:error, error}
    end
  end

  defp ssh_user({:error, message}, _) do
    Error.new(message)
  end

  # Функция построения пароля ssh
  defp ssh_password({ :ok, entity }, new_ssh_password) do
    case SshData.valid(new_ssh_password) do
      {:ok, _} -> Success.new(Map.put(entity, :ssh_password, new_ssh_password))
      {:error, error} -> {:error, error}
    end
  end

  defp ssh_password({:error, message}, _) do
    Error.new(message)
  end

  # Функция построения долготы
  defp longitude({ :ok, entity }, new_longitude) do
    case Longitude.valid(new_longitude) do
      {:ok, _} -> Success.new(Map.put(entity, :longitude, new_longitude))
      {:error, error} -> {:error, error}
    end
  end

  defp longitude({:error, message}, _) do
    Error.new(message)
  end

  # Функция построения широты
  defp latitude({ :ok, entity }, new_latitude) do
    case Latitude.valid(new_latitude) do
      {:ok, _} -> Success.new(Map.put(entity, :latitude, new_latitude))
      {:error, error} -> {:error, error}
    end
  end

  defp latitude({:error, message}, _) do
    Error.new(message)
  end

  # Функция построения адреса
  defp address({ :ok, entity }, new_address) when is_binary(new_address) do
    Success.new(Map.put(entity, :address, new_address))
  end

  defp address({:ok, _}, _) do
    Error.new("Не валидный адрес")
  end

  defp address({:error, message}, _) do
    Error.new(message)
  end
end
