defmodule Core.Content.Builder do
  @moduledoc """
    Билдер сущности
  """

  alias UUID
  alias Core.Content.Entity

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

  alias Core.File.Builder, as: BuilderFile

  alias Core.Content.Validators.DisplayDuration

  @spec build(map()) :: Success.t() | Error.t()
  def build(%{
    display_duration: display_duration,
    file: file
  }) do
    entity()
      |> file(file)
      |> display_duration(display_duration)
  end

   # Функция построения базового контента
   defp entity do
    Success.new(%Entity{
      id: UUID.uuid4(),
      created: Date.utc_today,
      updated: Date.utc_today
    })
  end

  # Функция построения продолжительности
  defp display_duration({ :ok, entity }, new_display_duration) when is_struct(entity) do
    case DisplayDuration.valid(new_display_duration) do
      {:ok, _} -> Success.new(Map.put(entity, :display_duration, new_display_duration))
      {:error, message} -> {:error, message}
    end
  end

  defp display_duration({:error, message}, _) when is_binary(message) do
    Error.new(message)
  end

  # Функция построения файла
  defp file({ :ok, entity }, new_file) when is_struct(entity) do
    case BuilderFile.build(new_file) do
      {:ok, file_entity} -> Success.new(Map.put(entity, :file, file_entity))
      {:error, message} -> {:error, message}
    end
  end

  defp file({:error, message}, _) when is_binary(message) do
    Error.new(message)
  end
end
