defmodule Core.Playlist.Ports.Transformer do
  @moduledoc """
    Порт вносящий изменения в хранилище(вставка или обновление)
  """

  alias Core.Playlist.Entity, as: Playlist
  alias Core.User.Entity, as: User
  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error
  alias Core.Shared.Types.Exception

  @type t :: __MODULE__

  @callback transform(Playlist.t(), User.t()) ::  Success.t() | Error.t() | Exception.t()
end
