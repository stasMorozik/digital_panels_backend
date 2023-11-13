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

  alias Core.Device.Types.Filter
  alias Core.Device.Types.Sort

  alias Core.Shared.Validators.Pagination

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
    with default_filter <- %{
          is_active: nil, 
          address: nil,
          ssh_host: nil, 
          created_f: nil,
          created_t: nil,
          updated_f: nil,
          updated_t: nil
         },
         filter <- Map.get(args, :filter, default_filter),
         default_sort <- %{
          is_active: nil, 
          created: nil, 
          updated: nil
         },
         sort <- Map.get(args, :sort, default_sort),
         default_pagi <- %{
          page: 1, 
          limit: 10
         },
         pagi <- Map.get(args, :pagi, default_pagi),
         {:ok, user} <- authorization_use_case.auth(
            getter_user, %{token: Map.get(args, :token, "")}
         ),
         {:ok, pagi} <- Pagination.valid(pagi),
         filter <- %Filter{
            user_id: UUID.string_to_binary!(user.id), 
            is_active: filter.is_active, 
            address: filter.address,
            ssh_host: filter.ssh_host,
            created_f: filter.created_f,
            created_t: filter.created_t,,
            updated_f: filter.updated_f,
            updated_t: filter.updated_t
         },
         sort <- %Sort{
            is_active: sort.is_active, 
            created: sort.created, 
            updated: sort.updated
         },
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
