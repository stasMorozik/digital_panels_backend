defmodule Content.FakeAdapters.Getting do
  alias Core.Content.Ports.Getter

  @behaviour Getter

  alias Core.Content.Entity, as: ContentEntity
  alias Core.User.Entity, as: UserEntity

  @impl Getter
  def get(id, %UserEntity{} = _) do
    case :mnesia.transaction (fn -> :mnesia.read({:contents, UUID.binary_to_string!(id)}) end) do
      {:atomic, list_contents} -> 
        case length(list_contents) > 0 do
          false -> {:error, "Контент не найден"}
          true -> 
            [content | _] = list_contents

            {:contents, id, name, duration, file, created, updated} = content

            {:ok, %ContentEntity{
              id: id,
              name: name,
              duration: duration,
              file: file,
              created: created,
              updated: updated
            }}
        end
      {:aborted, _} -> {:error, "Контент не найден"}
    end
  end
end