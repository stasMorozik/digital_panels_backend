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
    web_dav_url: web_dav_url,
    display_duration: display_duration,
    file: file
  }) when is_map(file) do
    entity()
      |> file(Map.put(file, :web_dav_url, web_dav_url))
      |> display_duration(display_duration)
  end

  def build(_) do
    Error.new("Не валидные данные для построения контента")
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
  defp display_duration({ :ok, entity }, new_display_duration) do
    case DisplayDuration.valid(new_display_duration) do
      {:ok, _} -> Success.new(Map.put(entity, :display_duration, new_display_duration))
      {:error, message} -> {:error, message}
    end
  end

  defp display_duration({:error, message}, _) do
    Error.new(message)
  end

  # Функция построения файла
  defp file({ :ok, entity }, new_file) do
    case BuilderFile.build(new_file) do
      {:ok, file_entity} -> Success.new(Map.put(entity, :file, file_entity))
      {:error, message} -> {:error, message}
    end
  end

  defp file({:error, message}, _) do
    Error.new(message)
  end
end
