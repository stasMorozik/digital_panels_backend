defmodule Content.FakeAdapters.GettingList do
  alias Core.Content.Ports.GetterList

  @behaviour GetterList

  alias Core.Content.Entity, as: ContentEntity
  alias Core.User.Entity, as: UserEntity

  alias Core.Shared.Types.Pagination
  alias Core.Content.Types.Filter
  alias Core.Content.Types.Sort

  @impl GetterList
  def get(%Pagination{} = _ , %Filter{} = filter, %Sort{} = _, %UserEntity{} = _) do
    case :mnesia.transaction (fn -> :mnesia.index_read(:contents, filter.name, :name) end) do
      {:atomic, list_contents} -> 
        case length(list_contents) > 0 do
          false -> {:ok, []}
          true -> 
            [content | _] = list_contents

            {:contents, id, name, duration, file, created, updated} = content

            {:ok, [%ContentEntity{
              id: id,
              name: name,
              duration: duration,
              file: file,
              created: created,
              updated: updated
            }]}
        end
      {:aborted, _} -> {:ok, []}
    end
  end
end