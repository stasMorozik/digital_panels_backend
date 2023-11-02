defmodule Core.Shared.Types.Exception do
  alias Core.Shared.Types.Exception

  @type t :: {:exception, binary()}

  @spec new(any()) :: Exception.t()
  def new(message) do
    {:exception, message}
  end
end
