defmodule Core.Task.Ports.Transformer do
  @moduledoc """
    Порт вносящий изменения в хранилище(вставка или обновление)
  """

  alias Core.Task.Entity, as: Task
  alias Core.User.Entity, as: User
  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error
  alias Core.Shared.Types.Exception

  @type t :: __MODULE__

  @callback transform(Task.t(), User.t()) ::  Success.t() | Error.t() | Exception.t()
end
