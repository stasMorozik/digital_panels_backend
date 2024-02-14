defmodule Schedule.FakeAdapters.Inserting do
  alias Core.Schedule.Ports.Transformer

  @behaviour Transformer

  alias Core.Schedule.Entity, as: ScheduleEntity
  alias Core.User.Entity, as: UserEntity

  @impl Transformer
  def transform(%ScheduleEntity{} = schedule, %UserEntity{} = _) do
    case :mnesia.transaction(
      fn -> :mnesia.write({
        :schedules, 
        schedule.id, 
        schedule.name,
        schedule.timings,
        schedule.group,
        schedule.created,
        schedule.updated
      }) end
    ) do
      {:atomic, :ok} -> {:ok, true}
      {:aborted, _} -> {:error, "Тайминг уже существует"}
    end
  end
end