defmodule Core.ConfirmationCode.Ports.Transformer do
  @moduledoc """
    Порт вносящий изменения в хранилище(вставка или обновление)
  """

  alias Core.ConfirmationCode.Entity

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

  @type t :: __MODULE__

  @callback transform(Entity.t()) ::  Success.t() | Error.t()
end
