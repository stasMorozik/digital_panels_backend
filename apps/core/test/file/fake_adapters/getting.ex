defmodule File.FakeAdapters.Getting do
  alias Core.File.Ports.Getter

  @behaviour Getter

  alias Core.File.Entity, as: FileEntity
  alias Core.User.Entity, as: UserEntity

  @impl Getter
  def get(id, %UserEntity{} = _) do
    case :mnesia.transaction (fn -> :mnesia.read({:files, id}) end) do
      {:atomic, list_files} -> 
        case length(list_files) > 0 do
          false -> {:error, "Файл не найден"}
          true -> 
            [file | _] = list_files

            {:files, id, path, url, extension, type, size, created} = file

            {:ok, %FileEntity{
              id: id,
              path: path,
              url: url,
              extension: extension,
              type: type,
              size: size,
              created: created
            }}
        end
      {:aborted, _} -> {:error, "Файл не найден"}
    end
  end
end