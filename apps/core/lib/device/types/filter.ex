defmodule Core.Device.Types.Filter do
  @moduledoc """

  """

  alias Core.Device.Types.Filter

  @type t :: %Filter{
    is_active: boolean() | none(),
    ssh_host: binary()   | none(),
    created: binary()    | none(),
    updated: binary()    | none()
  }

  defstruct is_active: nil, ssh_host: nil, created: nil, updated: nil
end
