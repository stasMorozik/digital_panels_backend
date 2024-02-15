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
        id: task.id,
        hash: task.hash,
        name: task.name,
        playlist: task.playlist,
        group: task.group,
        type: task.type,
        day: task.day,
        start_hour: task.start_hour,
        end_hour: task.end_hour,
        start_minute: task.start_minute,
        end_minute: task.end_minute,
        start_a: task.start,
        end_a: task.end,
        sum: task.sum,
        created: task.created,
        updated: task.updated
      }) end
    ) do
      {:atomic, :ok} -> {:ok, true}
      {:aborted, _} -> {:error, "Задание уже существует"}
    end
  end
end