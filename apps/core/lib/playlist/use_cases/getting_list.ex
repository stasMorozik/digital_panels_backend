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
    %{
      token: token,
      pagination: %{
        page: page,
        limit: limit
      },
      filter: %{
        name: name,
        created: created,
        updated: updated
      },
      sort: %{
        name: name,
        created: created,
        updated: updated
      }
    }
  ) when is_atom(authorization_use_case) and is_atom(getter_list) do
    with true <- Kernel.function_exported?(authorization_use_case, :auth, 2),
         true <- Kernel.function_exported?(getter_list, :get, 3),
         {:ok, _} <- authorization_use_case.auth(getter_user, %{token: token}),
         {:ok, pagi} <- Pagination.valid(%{
            page: page,
            limit: limit
         }),
         filter <- %Filter{name: name, created: created, updated: updated},
         sort <- %Sort{name: name, created: created, updated: updated},
         {:ok, list} <- getter_list.get(filter, sort, pagi) do
      Success.new(list)
    else
      false -> Error.new("Не валидные аргументы для получения списка плэйлстов")
      {:error, message} -> {:error, message}
    end
  end

  def get(_, _, _) do
    Error.new("Не валидные аргументы для получения списка плэйлстов")
  end
end