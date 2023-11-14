defmodule Core.Device.Types.Builders.Filter do
  @moduledoc """

  """

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error
  alias Core.Device.Types.Filter

  alias Core.Shared.Validators.Date
  alias Core.Shared.Validators.Boolean

  alias Core.Device.Validators.Address
  alias Core.Device.Validators.SshData

  @spec build(map()) :: Success.t() | Error.t()
  def build(%{
    is_active: is_active, 
    address:   address,
    ssh_host:  ssh_host, 
    created_f: created_f,
    created_t: created_t
  } = map) do
    type()
      |> is_nil(map, :created_f)
      |> created_f(created_f)
      |> is_nil(map, :created_t)
      |> created_t(created_t)
      |> is_nil(map, :address)
      |> address(address)
      |> is_nil(map, :ssh_host)
      |> ssh_host(ssh_host)
      |> is_nil(map, :is_active)
      |> is_active(is_active)
  end

  def build(_) do
    Error.new("Не валидные данные для фильтрации")
  end

  defp type do
    Success.new(%Filter{
      user_id: nil,
      is_active: nil, 
      address: nil, 
      ssh_host: nil, 
      created_f: nil,
      created_t: nil
    })
  end

  defp is_nil({:ok, type}, map, key) do
    case Map.get(map, key) do
      nil -> {:nil, type}
      _ -> {:ok, type}
    end
  end

  defp created_f({:ok, type}, date) do
    case Date.valid(date) do
      {:ok, date} -> Success.new(Map.put(type, :created_f, date))
      {:error, message} -> {:error, message}
    end
  end

  defp created_f({:nil, type}, _) do
    {:ok, type}
  end

  defp created_f({:error, message}, _) do
    {:error, message}
  end

  defp created_t({:ok, type}, date) do
    case Date.valid(date) do
      {:ok, date} -> Success.new(Map.put(type, :created_t, date))
      {:error, message} -> {:error, message}
    end
  end

  defp created_t({:nil, type}, _) do
    {:ok, type}
  end

  defp created_t({:error, message}, _) do
    {:error, message}
  end

  defp address({:ok, type}, address) do
    case Address.valid(address) do
      {:ok, _} -> Success.new(Map.put(type, :address, address))
      {:error, message} -> {:error, message}
    end
  end

  defp address({:nil, type}, _) do
    {:ok, type}
  end

  defp address({:error, message}, _) do
    {:error, message}
  end

  defp ssh_host({:ok, type}, ssh_host) do
    case SshData.valid(ssh_host) do
      {:ok, _} -> Success.new(Map.put(type, :ssh_host, ssh_host))
      {:error, message} -> {:error, message}
    end
  end

  defp ssh_host({:nil, type}, _) do
    {:ok, type}
  end

  defp ssh_host({:error, message}, _) do
    {:error, message}
  end

  defp is_active({:ok, type}, is_active) do
    case Boolean.valid(is_active) do
      {:ok, _} -> Success.new(Map.put(type, :is_active, is_active))
      {:error, message} -> {:error, message}
    end
  end

  defp is_active({:nil, type}, _) do
    {:ok, type}
  end

  defp is_active({:error, message}, _) do
    {:error, message}
  end
end