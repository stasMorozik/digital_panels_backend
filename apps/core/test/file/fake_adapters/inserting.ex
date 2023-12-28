defmodule File.FakeAdapters.Inserting do
  alias Core.File.Ports.Transformer

  @behaviour Transformer

  alias Core.File.Entity, as: FileEntity
  alias Core.User.Entity, as: UserEntity

  @impl Transformer
  def transform(%FileEntity{
    id: id,
    path: path,
    url: url,
    extension: extension,
    type: type,
    size: size,
    created: created
  }, %UserEntity{} = _) do
    case :mnesia.transaction(
      fn -> :mnesia.write({:files, id, path, url, extension, type, size, created}) end
    ) do
      {:atomic, :ok} -> {:ok, true}
      {:aborted, _} -> {:error, "Файл уже существует"}
    end
  end
end