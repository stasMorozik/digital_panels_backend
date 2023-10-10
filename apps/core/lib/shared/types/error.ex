defmodule Core.Shared.Types.Error do
  alias Core.Shared.Types.Error

  @type t :: {:error, binary()}

  @spec new(any()) :: Error.t()
  def new(message) do
    {:error, message}
  end
end
