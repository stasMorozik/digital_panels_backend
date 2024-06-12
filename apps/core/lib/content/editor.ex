defmodule Core.Content.Editor do
  @moduledoc """
    Редактор сущности
  """

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error
  alias Core.Content.Entity

  alias Core.Shared.Builders.BuilderProperties

  alias Core.Content.Validators.Name
  alias Core.Content.Validators.Duration
  alias Core.Content.Validators.SerialNumber
  alias Core.Content.Validators.Playlist
  alias Core.Content.Validators.File

  @spec edit(Entity.t(), map()) :: Success.t() | Error.t()
  def edit(%Entity{} = entity, args) when is_map(args) do
    setter = fn (
      entity, 
      key, 
      value
    ) -> 
      Map.put(entity, key, value) 
    end

    entity(entity)
      |> name(Map.get(args, :name), setter)
      |> duration(Map.get(args, :duration), setter)
      |> file(Map.get(args, :file), setter)
      |> playlist(Map.get(args, :playlist), setter)
      |> serial_number(Map.get(args, :serial_number), setter)
  end

  def edit(_, _) do
    {:error, "Невалидные данные для редактирования контента"}
  end

  defp entity(%Entity{} = entity) do
    {:ok, %Entity{
      id: entity.id,
      name: entity.name,
      duration: entity.duration,
      file: entity.file,
      playlist: entity.playlist,
      serial_number: entity.serial_number,
      created: entity.created, 
      updated: Date.utc_today
    }}
  end

  defp name({:ok, entity}, name, setter) do
    case name do
      nil -> {:ok, entity}
      name -> BuilderProperties.build({:ok, entity}, Name, setter, :name, name)
    end
  end

  defp name({:error, message}, _, _) do
    {:error, message}
  end

  defp duration({:ok, entity}, duration, setter) do
    case duration do
      nil -> {:ok, entity}
      duration -> BuilderProperties.build({:ok, entity}, Duration, setter, :duration, duration)
    end
  end

  defp duration({:error, message}, _, _) do
    {:error, message}
  end

  defp file({:ok, entity}, file, setter) do
    case file do
      nil -> {:ok, entity}
      file -> BuilderProperties.build({:ok, entity}, File, setter, :file, file)
    end
  end

  defp file({:error, message}, _, _) do
    {:error, message}
  end

  defp playlist({:ok, entity}, playlist, setter) do
    case playlist do
      nil -> {:ok, entity}
      playlist -> BuilderProperties.build({:ok, entity}, Playlist, setter, :playlist, playlist)
    end
  end

  defp playlist({:error, message}, _, _) do
    {:error, message}
  end

  defp serial_number({:ok, entity}, serial_number, setter) do
    case serial_number do
      nil -> {:ok, entity}
      serial_number -> BuilderProperties.build({:ok, entity}, SerialNumber, setter, :serial_number, serial_number)
    end
  end

  defp serial_number({:error, message}, _, _) do
    {:error, message}
  end
end