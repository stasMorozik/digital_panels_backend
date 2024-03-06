defmodule Core.Content.Builder do
  @moduledoc """
    Билдер сущности
  """
  
  alias UUID
  
  @spec build(map()) :: Success.t() | Error.t()
  def build(%{
    duration: duration, 
    file: file, 
    name: name, 
    playlist: playlist, 
    serial_number: serial_number
  }) do    
    entity()
      |> Core.Content.Builders.Name.build(name)
      |> Core.Content.Builders.Duration.build(duration)
      |> Core.Content.Builders.File.build(file)
      |> Core.Content.Builders.Playlist.build(playlist)
      |> Core.Content.Builders.SerialNumber.build(serial_number)
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