defmodule Core.Shared.Ports.Notifier do
  @moduledoc """
    Порт отправлюищй уведомления
  """

  @type t :: __MODULE__

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error
  alias Core.Shared.Types.Exception

  @callback notify(Core.Shared.Types.Notification.t()) :: Success.t() | Error.t() | Exception.t()
end
