defmodule Core.File.Ports.Transformer do
  @moduledoc """
    Порт вносящий изменения в хранилище(вставка или обновление)
  """

  alias Core.File.Entity, as: FileEntity
  alias Core.User.Entity, as: UserEntity
  
  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error
  alias Core.Shared.Types.Exception

  @type t :: __MODULE__

  @callback transform(
    FileEntity.t(), 
    UserEntity.t()
  ) ::  Success.t() | Error.t() | Exception.t()
end
