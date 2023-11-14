defmodule Core.Device.UseCases.GettingList do
  @moduledoc """
    Юзекейз получения списка плэйлистов
  """

  alias Core.Device.Ports.GetterList

  alias Core.User.UseCases.Authorization
  alias User.Ports.Getter, as: GetterUser

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error
  alias Core.Shared.Types.Exception

  alias Core.Device.Types.Builders.Filter
  alias Core.Device.Types.Builders.Sort

  alias Core.Shared.Types.Builders.Pagi

  @spec get(
    Authorization.t(),
    GetterUser.t(),
    GetterList.t(),
    map()
  ) :: Success.t() | Error.t() | Exception.t()
  def get(
    authorization_use_case,
    getter_user,
    getter_list,
    args
  ) when is_atom(authorization_use_case) and is_atom(getter_list) and is_map(args) do
    with {:ok, user} <- authorization_use_case.auth(
            getter_user, %{token: Map.get(args, :token, "")}
         ),
         {:ok, pagi} <- Pagi.build(Map.get(args, :pagi)),
         {:ok, filter} <- Filter.build(Map.get(args, :filter)),
         filter <- Map.put(filter, :user_id, UUID.string_to_binary!(user.id)),
         {:ok, sort} <- Sort.build(Map.get(args, :sort)),
         {:ok, list} <- getter_list.get(filter, sort, pagi) do
      Success.new(list)
    else
      {:error, message} -> {:error, message}
      {:exception, message} -> {:exception, message}
    end
  end

  def get(_, _, _, _) do
    Error.new("Не валидные аргументы для получения списка устройств")
  end
end
