defmodule Core.Device.Types.Filter do
  @moduledoc """

  """

  alias Core.Device.Types.Filter

  @type t :: %Filter{
    user_id:   binary(),
    is_active: boolean() | none(),
    address:   binary()  | none(),
    ssh_host:  binary()  | none(),
    created_f: binary()  | none(),
    created_t: binary()  | none(),
  }

  defstruct user_id: nil,
            is_active: nil, 
            address: nil, 
            ssh_host: nil, 
            created_f: nil,
            created_t: nil
end
