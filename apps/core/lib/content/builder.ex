defmodule Core.Content.Builder do
  @moduledoc """
    Билдер сущности
  """
  
  alias UUID

  alias Core.Shared.Builders.BuilderProperties

  alias Core.Content.Validators.Name
  alias Core.Content.Validators.Duration
  alias Core.Content.Validators.SerialNumber
  alias Core.Content.Validators.Playlist
  alias Core.Content.Validators.File
  
  @spec build(map()) :: Success.t() | Error.t()
  def build(%{
    duration: duration, 
    file: file, 
    name: name, 
    playlist: playlist, 
    serial_number: serial_number
  }) do
    setter = fn (
      entity, 
      key, 
      value
    ) -> 
      Map.put(entity, key, value) 
    end

    entity()
      |> BuilderProperties.build(Name, setter, :name, name) 
      |> BuilderProperties.build(Duration, setter, :duration, duration)
      |> BuilderProperties.build(File, setter, :file, file)
      |> BuilderProperties.build(Playlist, setter, :playlist, playlist)
      |> BuilderProperties.build(SerialNumber, setter, :serial_number, serial_number)
  end

  def build(_) do
    {:error, "Невалидные данные для построения контента"}
  end

  defp entity do
    {:ok, %Core.Content.Entity{
      id: UUID.uuid4(), 
      created: Date.utc_today,
      updated: Date.utc_today
    }}
  end
end