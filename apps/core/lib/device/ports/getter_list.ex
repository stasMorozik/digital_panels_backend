defmodule Core.Device.Ports.GetterList do
  @moduledoc """
    Порт получающий данные из хранилища и преобразующий их в список сущностей
  """

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error
  alias Core.Shared.Types.Exception

  alias Core.Shared.Types.Pagination

  @type t :: __MODULE__

  @callback get(Pagination.t()) ::  Success.t() | Error.t() | Exception.t()
end
