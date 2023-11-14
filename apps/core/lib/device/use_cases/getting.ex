defmodule Core.Device.UseCases.Getting do
  @moduledoc """
    Юзекейз получения устройства
  """

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error
  alias Core.Shared.Types.Exception
  
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

    with :ok <- result,
         {:ok, _} <- authorization_use_case.auth(
            getter_user, %{token: Map.get(args, :token, "")}
         ),
         {:ok, device} <- getter.get(UUID.string_to_binary!(args.id)) do
      Success.new(device)
    else
      :error -> Error.new("Не валидный UUID устройства")
      {:error, message} -> {:error, message}
      {:exception, message} -> {:exception, message}
    end
  end

  def get(_, _, _, _) do
    Error.new("Не валидные аргументы для получения устройства")
  end
end