defmodule Group.FakeAdapters.GettingList do
  alias Core.Group.Ports.GetterList

  @behaviour GetterList

  alias Core.Group.Entity, as: GroupEntity
  alias Core.User.Entity, as: UserEntity

  alias Core.Shared.Types.Pagination
  alias Core.Group.Types.Filter
  alias Core.Group.Types.Sort

  @impl GetterList
  def get(%Pagination{} = _ , %Filter{} = filter, %Sort{} = _, %UserEntity{} = _) do
    case :mnesia.transaction (fn -> :mnesia.index_read(:files, filter.type, :type) end) do
      {:atomic, list_files} -> 
        case length(list_files) > 0 do
          false -> {:ok, []}
          true -> 
            [file | _] = list_files

            {:files, id, path, url, extension, type, size, created} = file

            {:ok, [%FileEntity{
              id: id,
              path: path,
              url: url,
              extension: extension,
              type: type,
              size: size,
              created: created
            }]}
        end
      {:aborted, _} -> {:ok, []}
    end
  end
end