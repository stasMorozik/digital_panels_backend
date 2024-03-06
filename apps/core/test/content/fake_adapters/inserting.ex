defmodule Content.FakeAdapters.Inserting do
  alias Core.Content.Ports.Transformer

  @behaviour Transformer

  alias Core.Content.Entity, as: ContentEntity
  alias Core.User.Entity, as: UserEntity

  @impl Transformer
  def transform(%ContentEntity{} = content, %UserEntity{} = _) do
    case :mnesia.transaction(
      fn -> :mnesia.write({
        :contents, 
        content.id, 
        content.name, 
        content.duration, 
        content.file,
        content.playlist,
        content.serial_number, 
        content.created, 
        content.updated
      }) end
    ) do
      {:atomic, :ok} -> {:ok, true}
      {:aborted, _} -> {:error, "Контент уже существует"}
    end
  end
end