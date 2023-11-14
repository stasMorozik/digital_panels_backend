defmodule Core.Device.Types.Sort do
  @moduledoc """

  """

  alias Core.Device.Types.Sort

  @type t :: %Sort{
    is_active: boolean() | none(),
    created:   binary()  | none()
  }

  defstruct is_active: nil, created: nil
end
