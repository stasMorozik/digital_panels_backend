defmodule Core.Device.UseCases.Updating do
  
  alias Core.User.UseCases.Authorization

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error
  alias Core.Shared.Types.Exception

  @spec update(
    Core.User.Ports.Getter.t(),
    Core.Device.Ports.Getter.t(),
    Core.Device.Ports.Transformer.t(),
    map()
  ) :: Success.t() | Error.t() | Exception.t()
  def update(
    getter_user,
    getter_device,  
    transformer_device, 
    args
  ) when is_atom(getter_user) and
         is_atom(getter_device) and 
         is_atom(transformer_device) and
         is_map(args) do
    
    {result, _} = UUID.info(Map.get(args, :id))

    with :ok <- result,
         {:ok, user} <- Authorization.auth(getter_user, args),
         {:ok, device} <- getter_device.get(UUID.string_to_binary!(args.id), user),
         {:ok, device} <- Core.Device.Editor.edit(device, args),
         {:ok, _} <- transformer_device.transform(device, user) do
      {:ok, true}
    else
      :error -> {:error, "Не валидный UUID устройства"}
      {:error, message} -> {:error, message}
      {:exception, message} -> {:exception, message}
    end
  end

  def update(_, _, _, _) do
    {:error, "Невалидные данные для обновления устройства"}
  end
end