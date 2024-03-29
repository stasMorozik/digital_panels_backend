defmodule Core.Device.UseCases.Updating do
  
  alias Core.User.UseCases.Authorization

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error
  alias Core.Shared.Types.Exception

  @spec update(
    Core.User.Ports.Getter.t(),
    Core.Group.Ports.Getter.t(),
    Core.Device.Ports.Getter.t(),
    Core.Device.Ports.Transformer.t(),
    map()
  ) :: Success.t() | Error.t() | Exception.t()
  def update(
    getter_user,
    getter_group,
    getter_device,  
    transformer_device, 
    args
  ) when is_atom(getter_user) and
         is_atom(getter_group) and
         is_atom(getter_device) and 
         is_atom(transformer_device) and
         is_map(args) do
    with {:ok, user} <- Authorization.auth(getter_user, args),
         {:ok, true} <- Core.Shared.Validators.Identifier.valid(Map.get(args, :id)),
         {:ok, true} <- Core.Shared.Validators.Identifier.valid(Map.get(args, :group_id)),
         {:ok, device} <- getter_device.get(args.id, user),
         {:ok, group} <- getter_group.get(args.group_id, user),
         args <- Map.put(args, :group, case group.id == device.group.id do
            true -> nil
            false -> group
         end),
         {:ok, device} <- Core.Device.Editor.edit(device, args),
         {:ok, true} <- transformer_device.transform(device, user) do
      {:ok, true}
    else
      {:error, message} -> {:error, message}
      {:exception, message} -> {:exception, message}
    end
  end

  def update(_, _, _, _, _) do
    {:error, "Невалидные данные для обновления устройства"}
  end
end