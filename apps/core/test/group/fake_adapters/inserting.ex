defmodule Group.FakeAdapters.Inserting do
  alias Core.Group.Ports.Transformer

  @behaviour Transformer

  alias Core.Group.Entity, as: GroupEntity
  alias Core.User.Entity, as: UserEntity

  @impl Transformer
  def transform(%GroupEntity{} = group, %UserEntity{} = _) do
    case :mnesia.transaction(
      fn -> :mnesia.write({
        :groups, 
        group.id, 
        group.name,
        group.sum, 
        group.devices,
        group.created,
        group.updated
      }) end
    ) do
      {:atomic, :ok} -> {:ok, true}
      {:aborted, _} -> {:error, "Группа уже существует"}
    end
  end
end