defmodule Core.Shared.Ports.Notifier do
  @moduledoc """
    Порт отправлюищй уведомления
  """

  @type t :: __MODULE__

  @type notification :: %{
    to: binary(),
    from: binary(),
    subject: binary(),
    message: binary()
  }

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

  @callback notify(notification()) ::  Success.t() | Error.t()
end
