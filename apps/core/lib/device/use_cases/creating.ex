defmodule Core.Device.UseCases.Creating do
  @moduledoc """
    Юзекейз создания устройства
  """

  alias Core.Device.Builder
  alias Core.Device.Ports.Transformer

  alias Core.User.UseCases.Authorization
  alias User.Ports.Getter

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

  @spec create(
    Authorization.t(),
    Getter.t(),
    Transformer.t(),
    map()
  ) :: Success.t() | Error.t()
  def create(
    authorization_use_case,
    getter_user,
    transformer,
    args
  ) when is_atom(authorization_use_case)
    and is_atom(transformer)
    and is_map(args) do
      with true <- Kernel.function_exported?(authorization_use_case, :auth, 2),
           true <- Kernel.function_exported?(transformer, :transform, 2),
           {:ok, user} <- authorization_use_case.auth(getter_user, args),
           {:ok, device} <- Builder.build(%{
            ssh_port: Map.get(args, :ssh_port, ""),
            ssh_host: Map.get(args, :ssh_host, ""),
            ssh_user: Map.get(args, :ssh_user, ""),
            ssh_password: Map.get(args, :ssh_password, ""),
            address: Map.get(args, :address, ""),
            longitude: Map.get(args, :longitude, ""),
            latitude: Map.get(args, :latitude, "")
           }),
           {:ok, _} <- transformer.transform(device, user) do
        Success.new(true)
      else
        false -> Error.new("Не валидные аргументы для создания устройства")
        {:error, message} -> {:error, message}
      end
  end
end
