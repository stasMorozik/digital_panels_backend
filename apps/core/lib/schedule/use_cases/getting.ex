defmodule Core.Schedule.UseCases.Getting do
  
  alias Core.User.UseCases.Authorization

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error
  alias Core.Shared.Types.Exception

  @spec get(
    Core.User.Ports.Getter.t(),
    Core.Schedule.Ports.Getter.t(),
    map()
  ) :: Success.t() | Error.t() | Exception.t()
  def get(
    getter_user,
    getter_schedule,
    args
  ) when is_atom(getter_user) and 
         is_atom(getter_schedule) and
         is_map(args) do
    
    {result, _} = UUID.info(Map.get(args, :id))

    with :ok <- result,
         {:ok, user} <- Authorization.auth(getter_user, args),
         {:ok, schedule} <- getter_schedule.get(UUID.string_to_binary!(args.id), user) do
      {:ok, schedule}
    else
      :error -> {:error, "Не валидный UUID расписания"}
      {:error, message} -> {:error, message}
      {:exception, message} -> {:exception, message}
    end
  end

  def get(_, _, _) do
    {:error, "Невалидные данные для получения расписания"}
  end
end