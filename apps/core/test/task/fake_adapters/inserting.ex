defmodule Task.FakeAdapters.Inserting do
  alias Core.Task.Ports.Transformer

  @behaviour Transformer

  alias Core.Task.Entity, as: TaskEntity
  alias Core.User.Entity, as: UserEntity

  @impl Transformer
  def transform(%TaskEntity{} = task, %UserEntity{} = _) do
    case :mnesia.transaction(
      fn -> :mnesia.write({
        :tasks, 
        task.id, 
        task.hash,
        task.name,
        task.playlist,
        task.group,
        task.type,
        task.day,
        task.start_hour,
        task.end_hour,
        task.start_minute,
        task.end_minute,
        task.start,
        task.end,
        task.sum,
        task.created, 
        task.updated
      }) end
    ) do
      {:atomic, :ok} -> {:ok, true}
      {:aborted, _} -> {:error, "Задание уже существует"}
    end
  end
end