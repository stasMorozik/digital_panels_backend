defmodule Core.Shared.Ports.Pipe do
  @moduledoc """
    Порт отправлюищй что то в очередь
  """

  @type t :: __MODULE__

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error
  alias Core.Shared.Types.Exception

  @callback emit(any()) :: Success.t() | Error.t() | Exception.t()
end