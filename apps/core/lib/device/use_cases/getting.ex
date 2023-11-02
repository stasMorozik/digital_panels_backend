defmodule Core.Device.UseCases.Getting do
  @moduledoc """
    Юзекейз получения устройства
  """

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error
  alias Core.Shared.Types.Exception

  alias Core.Device.Types.Filter
  alias Core.Device.Types.Sort
  
  alias Core.User.UseCases.Authorization
  alias User.Ports.Getter, as: GetterUser

  alias Core.Device.Ports.Getter

  @spec get(
    Authorization.t(),
    GetterUser.t(),
    Getter.t(),
    map()
  ) :: Success.t() | Error.t() | Exception.t()
  def get(
    authorization_use_case,
    getter_user,
    getter,
    args
  ) when is_atom(authorization_use_case) and is_atom(getter) and is_map(args) do

    {result, _} = UUID.info(Map.get(args, :id))

    with true <- Kernel.function_exported?(authorization_use_case, :auth, 2),
         true <- Kernel.function_exported?(getter, :get, 1),
         :ok <- result,
         {:ok, user} <- authorization_use_case.auth(
            getter_user, %{token: Map.get(args, :token, "")}
         ),
         {:ok, device} <- getter.get(args.id) do
      Success.new(device)
    else
      false -> Error.new("Не валидные аргументы для получения устройства")
      {:error, message} -> {:error, message}
      :error -> Error.new("Не валидный UUID устройства: #{Map.get(args, :id)}")
      {:exception, message} -> {:exception, message}
    end
  end

  def get(_, _, _, _) do
    Error.new("Не валидные аргументы для получения устройства")
  end
end