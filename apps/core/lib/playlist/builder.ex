defmodule Core.Playlist.Builder do
  @moduledoc """
    Билдер сущности
  """

  alias UUID
  alias Core.Playlist.Entity
  alias Core.Playlist.Validators.Contents

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

  alias Core.Content.Builder

  @spec build(map()) :: Success.t() | Error.t()
  def build(%{
    name: name,
    contents: contents
  }) do
    entity()
      |> contents(ssh_port)
  end

   # Функция построения базового плэйлиста
   defp entity do
    Success.new(%Entity{
      id: UUID.uuid4(),
      created: Date.utc_today,
      updated: Date.utc_today
    })
  end

  # Функция построения контента
  defp contents({ :ok, entity }, contents) when length(contents) > 0 and is_struct(entity) do
    with cnts <- handle_contents({:ok, contents}),
         nil <- Enum.find(cnts, fn tuple -> elem(tuple, 0) == :error end) do
      {:ok, cnts}
    else
      {:error, message} -> {:error, message}
    end
  end

  defp contents({ :ok, entity }, contents) when length(contents) == 0 and is_struct(entity) do
    {:error, "Пустой список контента"}
  end

  defp contents({:error, message}, _) when is_binary(message) do
    Error.new(message)
  end

  defp handle_contents([head | tail]) do
    case Builder.build(head) do
      {:ok, content_entity} -> [content_entity | handle_contents(tail) ]
      {:error, message} -> {:error, message}
    end
  end

  defp handle_contents({:ok, []}) do
    {:ok, []}
  end
end
