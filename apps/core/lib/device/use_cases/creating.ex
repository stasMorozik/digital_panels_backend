defmodule Core.Device.UseCases.Creating do
  @moduledoc """
    Юзекейз создания устройства
  """

  alias Core.Device.Builder
  alias Core.Device.Ports.Transformer

  alias Core.User.UseCases.Authorization
  alias User.Ports.Getter, as: GetterUser
  
  alias Core.Playlist.Ports.Getter, as: GetterPlaylist

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error
  alias Core.Shared.Types.Exception

  @spec create(
    Authorization.t(),
    GetterUser.t(),
    GetterPlaylist.t(),
    Transformer.t(),
    map()
  ) :: Success.t() | Error.t() | Exception.t()
  def create(
    authorization_use_case,
    getter_user,
    getter_playlist,
    transformer,
    args
  ) when is_atom(authorization_use_case)
    and is_atom(transformer)
    and is_map(args) do

      {result, _} = UUID.info(Map.get(args, :playlist_id))

      with {:ok, user} <- authorization_use_case.auth(getter_user, args),
           :ok <- result,
           {:ok, playlist} <- getter_playlist.get(
            UUID.string_to_binary!(args.playlist_id)
           ),
           {:ok, device} <- Builder.build(args),
           {:ok, _} <- transformer.transform(device, user, playlist) do
        Success.new(true)
      else
        :error -> Error.new("Не валидный UUID плэйлиста")
        {:error, message} -> {:error, message}
        {:exception, message} -> {:exception, message}
      end
  end

  def create(_, _, _, _, _) do
    Error.new("Не валидные аргументы для создания устройства")
  end
end
