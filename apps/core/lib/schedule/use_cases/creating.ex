defmodule Core.Schedule.UseCases.Creating do
  
  alias Core.User.UseCases.Authorization

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error
  alias Core.Shared.Types.Exception

  @spec create(
    Core.User.Ports.Getter.t(),
    Core.Playlist.Ports.Getter.t(),
    Core.Group.Ports.Getter.t(),
    Core.Schedule.Ports.Transformer.t(),
    map()
  ) :: Success.t() | Error.t() | Exception.t()
  def create(
    getter_user,
    getter_playlist,
    getter_group,
    transformer_schedule, 
    args
  ) when is_atom(getter_user) and 
         is_atom(getter_playlist) and 
         is_atom(transformer_schedule) and
         is_map(args) do

    {result, _} = UUID.info(Map.get(args, :group_id))
  
    with {:ok, user} <- Authorization.auth(getter_user, args),
         :ok <- result,
         {:ok, timings} <- Map.fetch(args, :timings),
         true <- is_list(timings),
         validated <- Enum.map(timings, fn maybe_map -> is_map(maybe_map) end),
         maybe_nil <- Enum.find(validated, fn bool -> bool == false end),
         true <- maybe_nil == nil,
         validated <- Enum.map(timings, fn timing -> UUID.info(Map.get(timing, :playlist_id)) end),
         maybe_nil <- Enum.find(validated, fn {result, _} -> result == :error end),
         true <- maybe_nil == nil,
         fun <- fn (timing) -> 
            tuple = getter_playlist.get(UUID.string_to_binary!(timing.playlist_id), user)
            Map.put(timing, :playlist, tuple)
         end,
         timings <- Enum.map(timings, fun),
         maybe_nil <- Enum.find(timings, fn timing -> elem(timing.playlist, 0) == :error end),
         true <- maybe_nil == nil,
         fun <- fn (timing) ->
            Map.put(timing, :playlist, elem(timing.playlist, 1))
         end,
         timings <- Enum.map(timings, fun),
         {:ok, group} <- getter_group.get(UUID.string_to_binary!(args.group_id), user),
         args <- Map.put(args, :group, group),
         args <- Map.put(args, :timings, timings),
         {:ok, schedule} <- Core.Schedule.Builder.build(args),
         {:ok, true} <- transformer_schedule.transform(schedule, user) do
      {:ok, true}
    else
      false -> {:error, "Невалидные данные для создания расписания"}
      :error -> {:error, "Не валидный UUID группы"}
      {:error, message} -> {:error, message}
      {:exception, message} -> {:exception, message}
    end
  end

  def create(_, _, _, _) do
    {:error, "Невалидные данные для создания расписания"}
  end
end