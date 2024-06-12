defmodule Core.Assembly.Validators.Url do
  
  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

  @spec valid(any()) :: Success.t() | Error.t()
  def valid(path) when is_binary(path) do
    {:ok, true}
  end

  def valid(_) do
    {:error, "Невалидный url"}
  end
end