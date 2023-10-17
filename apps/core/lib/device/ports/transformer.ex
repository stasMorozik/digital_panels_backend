defmodule Core.Device.Ports.Transformer do
  @moduledoc """
    Порт вносящий изменения в хранилище(вставка или обновление)
  """

  alias Core.Device.Entity, as: DeviceEntity
  alias Core.Device.Entity, as: UserEntity
  alias Core.Playlist.Entity, as: PlaylistEntity
  
  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

  @type t :: __MODULE__

  @callback transform(
    DeviceEntity.t(), 
    UserEntity.t(), 
    PlaylistEntity.t()
  ) ::  Success.t() | Error.t()
end
