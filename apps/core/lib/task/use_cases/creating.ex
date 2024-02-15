defmodule Core.Task.UseCases.Creating do
  
  alias Core.User.UseCases.Authorization

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error
  alias Core.Shared.Types.Exception

  @spec create(
    Core.User.Ports.Getter.t(),
    Core.Playlist.Ports.Getter.t(),
    Core.Group.Ports.Getter.t(),
    Core.Task.Ports.Getter.t(),
    Core.Task.Ports.Transformer.t(),
    map()
  ) :: Success.t() | Error.t() | Exception.t()
  def create(
    getter_user,
    getter_playlist,
    getter_group,
    getter_task,
    transformer_task, 
    args
  ) when is_atom(getter_user) and 
         is_atom(getter_playlist) and
         is_atom(getter_group) and
         is_atom(getter_task) and
         is_atom(transformer_task) and
         is_map(args) do
    with {:ok, user} <- Authorization.auth(getter_user, args),
         playlist_id <- Map.get(args, :playlist_id),
         group_id <- Map.get(args, :group_id),
         {:ok, true} <- Core.Shared.Validators.Identifier.valid(playlist_id),
         {:ok, true} <- Core.Shared.Validators.Identifier.valid(group_id),
         {:ok, playlist} <- getter_playlist.get(UUID.string_to_binary!(playlist_id), user),
         {:ok, group} <- getter_group.get(UUID.string_to_binary!(group_id), user),
         args <- Map.put(args, :playlist, playlist),
         args <- Map.put(args, :group, group),
         {:ok, task} <- Core.Task.Builder.build(args) do
      case getter_task.get(task.hash, user) do
        {:error, _} -> transformer_task.transform(task, user)
        {:ok, ex_task} -> 
          args_0 = {task.start, task.end}
          args_1 = {ex_task.start, ex_task.end}

          case Core.Task.Validators.Entry.valid(args_0, args_1) do
            {:ok, true} -> transformer_task.transform(task, user)
            {:error, message} -> {:error, message}
          end  
      end
    else
      {:error, message} -> {:error, message}
      {:exception, message} -> {:exception, message}
    end
  end

  def create(_, _, _, _, _, _) do
    {:error, "Невалидные данные для создания задания"}
  end
end