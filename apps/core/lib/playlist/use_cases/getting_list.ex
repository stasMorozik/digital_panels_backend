defmodule Core.Playlist.UseCases.GettingList do
  @moduledoc """
    Юзекейз получения списка плэйлистов
  """

  alias Core.Playlist.Ports.GetterList

  alias Core.User.UseCases.Authorization
  alias User.Ports.Getter, as: GetterUser

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

  alias Core.Playlist.Types.Filter
  alias Core.Playlist.Types.Sort

  alias Core.Shared.Validators.Pagination

  @spec get(
    Authorization.t(),
    GetterUser.t(),
    GetterList.t(),
    map()
  ) :: Success.t() | Error.t()
  def get(
    authorization_use_case,
    getter_user,
    getter_list,
    args
  ) when is_atom(authorization_use_case) and is_atom(getter_list) and is_map(args) do
    with true <- Kernel.function_exported?(authorization_use_case, :auth, 2),
         true <- Kernel.function_exported?(getter_list, :get, 3),
         filter <- Map.get(args, :filter, %{name: nil, created: nil, updated: nil}),
         sort <- Map.get(args, :sort, %{name: nil, created: nil, updated: nil}),
         pagi <- Map.get(args, :pagi, %{page: 1, limit: 10}),
         {:ok, user} <- authorization_use_case.auth(
            getter_user, %{token: Map.get(args, :token, "")}
         ),
         {:ok, pagi} <- Pagination.valid(pagi),
         filter <- %Filter{
            user_id: user.id, 
            name: filter.name, 
            created: filter.created, 
            updated: filter.updated
         },
         sort <- %Sort{
            name: sort.name, 
            created: sort.created, 
            updated: sort.updated
         },
         {:ok, list} <- getter_list.get(filter, sort, pagi) do
      Success.new(list)
    else
      false -> Error.new("Не валидные аргументы для получения списка плэйлстов")
      {:error, message} -> {:error, message}
    end
  end

  def get(_, _, _, _) do
    Error.new("Не валидные аргументы для получения списка плэйлстов")
  end
end