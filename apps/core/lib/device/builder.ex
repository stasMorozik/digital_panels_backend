defmodule Core.Device.Builder do
  @moduledoc """
    Билдер сущности
  """

  alias UUID

  alias Core.Shared.Builders.BuilderProperties

  alias Core.Device.Validators.Ip
  alias Core.Device.Validators.Latitude
  alias Core.Device.Validators.Longitude
  alias Core.Device.Validators.Description
  alias Core.Device.Validators.Group

  @spec build(map()) :: Core.Shared.Types.Success.t() | Core.Shared.Types.Error.t()
  def build(%{
    ip: ip, 
    latitude: latitude, 
    longitude: longitude, 
    desc: desc, 
    group: group
  }) do
    setter = fn (
      entity, 
      key, 
      value
    ) -> 
      Map.put(entity, key, value) 
    end

    entity()
      |> BuilderProperties.build(Ip, setter, :ip, ip)
      |> BuilderProperties.build(Latitude, setter, :latitude, latitude)
      |> BuilderProperties.build(Longitude, setter, :longitude, longitude)
      |> BuilderProperties.build(Description, setter, :desc, desc)
      |> BuilderProperties.build(Group, setter, :group, group)
  end

  def build(_) do
    {:error, "Невалидные данные для построения устройства"}
  end

  # Функция построения базового устройства
  defp entity do
    {:ok, %Core.Device.Entity{
      id: UUID.uuid4(), 
      is_active: false,
      created: Date.utc_today, 
      updated: Date.utc_today
    }}
  end
end