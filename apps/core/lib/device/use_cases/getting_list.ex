defmodule Core.Device.UseCases.GettingList do
  alias Core.User.UseCases.Authorization

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error
  alias Core.Shared.Types.Exception

  @spec get(
    Core.User.Ports.Getter.t(),
    Core.Device.Ports.GetterList.t(),
    map()
  ) :: Success.t() | Error.t() | Exception.t()
  def get(
    getter_user,
    getter_list_device,
    args
  ) when is_atom(getter_user) and
         is_atom(getter_list_device) and
         is_map(args) do
    with {:ok, user} <- Authorization.auth(getter_user, args),
         {:ok, pagi} <- Core.Shared.Builders.Pagi.build(Map.get(args, :pagi, %{page: 1, limit: 10})),
         {:ok, filter} <- Core.Device.Builders.Filter.build(Map.get(args, :filter, %{})),
         {:ok, sort} <- Core.Device.Builders.Sort.build(Map.get(args, :sort, %{})),
         {:ok, list} <- getter_list_device.get(pagi, filter, sort, user) do
      {:ok, list}
    else
      {:error, message} -> {:error, message}
      {:exception, message} -> {:exception, message}
    end
  end

  def get(_, _, _) do
    {:error, "Невалидные данные для получения устройства"}
  end
end