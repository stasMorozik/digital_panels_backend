defmodule Core.Shared.Types.Success do
  alias Core.Shared.Types.Success

  @type t :: {:ok, any()}

  @spec new(any()) :: Success.t()
  def new(some) do
    {:ok, some}
  end
end
