defmodule Core.Device.UseCases.Creating do

  alias Core.User.UseCases.Authorization

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error
  alias Core.Shared.Types.Exception

  @spec create(
    Core.User.Ports.Getter.t(),
    Core.Device.Ports.Transformer.t(),
    map()
  ) :: Success.t() | Error.t() | Exception.t()
  def create(
    getter_user, 
    transformer_device, 
    args
  ) when is_atom(getter_user) and is_atom(transformer_device) and is_map(args) do
    with {:ok, user} <- Authorization.auth(getter_user, args),
         {:ok, device} <- Core.Device.Builder.build(args),
         {:ok, _} <- transformer_device.transform(device, user) do
      {:ok, true}
    else
      {:error, message} -> {:error, message}
      {:exception, message} -> {:exception, message}
    end
  end

  def create(_, _, _) do
    {:error, "Невалидные данные для создания устройства"}
  end
end