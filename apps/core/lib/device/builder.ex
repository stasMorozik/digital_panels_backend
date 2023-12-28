defmodule Core.Device.Builder do
  @moduledoc """
    Билдер сущности
  """

  alias UUID

  @spec build(map()) :: Core.Shared.Types.Success.t() | Core.Shared.Types.Error.t()
  def build(%{ip: ip, latitude: latitude, longitude: longitude, desc: desc}) do
    entity()
      |> Core.Device.Builders.Ip.build(ip)
      |> Core.Device.Builders.Latitude.build(latitude)
      |> Core.Device.Builders.Longitude.build(longitude)
      |> Core.Device.Builders.Description.build(desc)
  end

  def build(_) do
    {:error, "Невалидные данные для построения устройства"}
  end

  # Функция построения базового устройства
  defp entity do
    {:ok, %Core.Device.Entity{
      id: UUID.uuid4(), 
      created: Date.utc_today, 
      updated: Date.utc_today
    }}
  end
end