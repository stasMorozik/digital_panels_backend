defmodule Core.Task.UseCases.Creating do
  
  alias Core.User.UseCases.Authorization

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error
  alias Core.Shared.Types.Exception

  @spec create(
    Core.User.Ports.Getter.t(),
    Core.Playlist.Ports.Getter.t(),
    Core.Group.Ports.Getter.t(),
    Core.Task.Ports.GetterList.t(),
    Core.Task.Ports.Transformer.t(),
    map()
  ) :: Success.t() | Error.t() | Exception.t()
  def create(
    getter_user,
    getter_playlist,
    getter_group,
    getter_list_task,
    transformer_task, 
    args
  ) when is_atom(getter_user) and 
         is_atom(getter_playlist) and
         is_atom(getter_group) and
         is_atom(getter_list_task) and
         is_atom(transformer_task) and
         is_map(args) do
    with {:ok, user} <- Authorization.auth(getter_user, args),
         playlist_id <- Map.get(args, :playlist_id),
         group_id <- Map.get(args, :group_id),
         {:ok, true} <- Core.Shared.Validators.Identifier.valid(playlist_id),
         {:ok, true} <- Core.Shared.Validators.Identifier.valid(group_id),
         {:ok, group} <- getter_group.get(UUID.string_to_binary!(group_id), user),
         {:ok, playlist} <- getter_playlist.get(UUID.string_to_binary!(playlist_id), user),
         args <- Map.put(args, :playlist, playlist),
         args <- Map.put(args, :group, group),
         {:ok, task} <- Core.Task.Builder.build(args),
         {:ok, pagi} <- Core.Shared.Builders.Pagi.build(Map.get(args, :pagi, %{page: 1, limit: 2})),
         {:ok, filter} <- Core.Task.Builders.Filter.build(Map.get(args, :filter, %{
            start_hour: task.start_hour,
            start_minute: task.start_minute,
            end_hour: task.end_hour,
            end_minute: task.end_minute
         })),
         {:ok, sort} <- Core.Task.Builders.Sort.build(Map.get(args, :sort, %{})),
         {:ok, list} <- getter_list_task.get(pagi, filter, sort, user),
         true <- length(list) == 0,
         {:ok, true} <- transformer_task.transform(task, user) do
      {:ok, true}
    else
      false -> {:error, "Время показа на выбранный день уже занято"}
      {:error, message} -> {:error, message}
      {:exception, message} -> {:exception, message}
    end
  end

  def create(_, _, _, _, _, _) do
    {:error, "Невалидные данные для создания задания"}
  end
end