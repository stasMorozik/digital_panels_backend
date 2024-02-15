defmodule Core.Task.Ports.Getter do
  @moduledoc """
    Порт получающий данные из хранилища и преобразующий их в сущность
  """

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error
  alias Core.Shared.Types.Exception

  alias Core.User.Entity, as: User

  @type t :: __MODULE__

  @callback get(binary(), User.t()) ::  Success.t() | Error.t() | Exception.t()
end
