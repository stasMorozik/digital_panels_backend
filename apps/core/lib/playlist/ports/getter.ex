defmodule Core.Playlist.Ports.Getter do
  @moduledoc """
    Порт получающий данные из хранилища и преобразующий их в сущность
  """

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error
  alias Core.Shared.Types.Exception

  @type t :: __MODULE__

  @callback get(binary()) ::  Success.t() | Error.t() | Exception.t()
end
