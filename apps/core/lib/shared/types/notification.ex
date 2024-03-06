defmodule Core.Shared.Types.Notification do
  @type t :: %Core.Shared.Types.Notification{
    to: binary(),
    from: binary(),
    subject: binary(),
    message: binary()
  }

  defstruct to: "", from: "", subject: "", message: ""
end