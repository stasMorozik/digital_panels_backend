defmodule Core.Device.UseCases.Creating do

  alias Core.User.UseCases.Authorization

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error
  alias Core.Shared.Types.Exception

  @spec create(
    Core.User.Ports.Getter.t(),
    Core.Group.Ports.Getter.t(),
    Core.Device.Ports.Transformer.t(),
    map()
  ) :: Success.t() | Error.t() | Exception.t()
  def create(
    getter_user,
    getter_group, 
    transformer_device, 
    args
  ) when is_atom(getter_user) and 
         is_atom(getter_group) and
         is_atom(transformer_device) and
         is_map(args) do

    {result, _} = UUID.info(Map.get(args, :group_id))
    
    with {:ok, user} <- Authorization.auth(getter_user, args),
         :ok <- result,
         {:ok, group} <- getter_group.get(UUID.string_to_binary!(args.group_id), user),
         {:ok, group} <- Core.Group.Editor.edit(group, %{sum: group.sum + 1}),
         args <- Map.put(args, :group, group),
         {:ok, device} <- Core.Device.Builder.build(args),
         {:ok, _} <- transformer_device.transform(device, user) do
      {:ok, true}
    else
      :error -> {:error, "Не валидный UUID группы"}
      {:error, message} -> {:error, message}
      {:exception, message} -> {:exception, message}
    end
  end

  def create(_, _, _, _) do
    {:error, "Невалидные данные для создания устройства"}
  end
end