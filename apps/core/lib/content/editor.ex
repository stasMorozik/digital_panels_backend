defmodule Core.Content.Editor do
  @moduledoc """
    Редактор сущности
  """

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error
  alias Core.Content.Entity

  @spec edit(Entity.t(), map()) :: Success.t() | Error.t()
  def edit(%Entity{} = entity, args) when is_map(args) do
    entity(entity)
      |> name(Map.get(args, :name))
      |> duration(Map.get(args, :duration))
      |> file(Map.get(args, :file))
      |> playlist(Map.get(args, :playlist))
      |> serial_number(Map.get(args, :serial_number))
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

  defp name({:ok, entity}, name) do
    case name do
      nil -> {:ok, entity}
      name -> Core.Content.Builders.Name.build({:ok, entity}, name)
    end
  end

  defp name({:error, message}, _) do
    {:error, message}
  end

  defp duration({:ok, entity}, duration) do
    case duration do
      nil -> {:ok, entity}
      duration -> Core.Content.Builders.Duration.build({:ok, entity}, duration)
    end
  end

  defp duration({:error, message}, _) do
    {:error, message}
  end

  defp file({:ok, entity}, file) do
    case file do
      nil -> {:ok, entity}
      file -> Core.Content.Builders.File.build({:ok, entity}, file)
    end
  end

  defp file({:error, message}, _) do
    {:error, message}
  end

  defp playlist({:ok, entity}, playlist) do
    case playlist do
      nil -> {:ok, entity}
      playlist -> Core.Content.Builders.Playlist.build({:ok, entity}, playlist)
    end
  end

  defp playlist({:error, message}, _) do
    {:error, message}
  end

  defp serial_number({:ok, entity}, serial_number) do
    case serial_number do
      nil -> {:ok, entity}
      serial_number -> Core.Content.Builders.SerialNumber.build({:ok, entity}, serial_number)
    end
  end

  defp serial_number({:error, message}, _) do
    {:error, message}
  end
end