defmodule Core.Task.UseCases.Getting do
  
  alias Core.User.UseCases.Authorization

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error
  alias Core.Shared.Types.Exception

  @spec get(
    Core.User.Ports.Getter.t(),
    Core.Task.Ports.Getter.t(),
    map()
  ) :: Success.t() | Error.t() | Exception.t()
  def get(
    getter_user,
    getter_task,
    args
  ) when is_atom(getter_user) and 
         is_atom(getter_task) and
         is_map(args) do
    with {:ok, user} <- Authorization.auth(getter_user, args),
         {:ok, true} <- Core.Shared.Validators.Identifier.valid(Map.get(args, :id)),
         {:ok, task} <- getter_task.get(UUID.string_to_binary!(args.id), user) do
      {:ok, task}
    else
      {:error, message} -> {:error, message}
      {:exception, message} -> {:exception, message}
    end
  end

  def get(_, _, _) do
    {:error, "Невалидные данные для получения задания"}
  end
end