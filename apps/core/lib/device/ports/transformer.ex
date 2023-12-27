defmodule Core.Device.Ports.Transformer do
  @moduledoc """
    Порт вносящий изменения в хранилище(вставка или обновление)
  """

  alias Core.Device.Entity, as: Device
  alias Core.User.Entity, as: User
  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error
  alias Core.Shared.Types.Exception

  @type t :: __MODULE__

  @callback transform(Device.t(), User.t()) ::  Success.t() | Error.t() | Exception.t()
end
