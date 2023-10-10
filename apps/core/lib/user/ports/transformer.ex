defmodule Core.User.Ports.Transformer do
  @moduledoc """
    Порт вносящий изменения в хранилище(вставка или обновление)
  """

  alias Core.User.Entity
  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

  @type t :: __MODULE__

  @callback transform(Entity.t()) ::  Success.t() | Error.t()
end
