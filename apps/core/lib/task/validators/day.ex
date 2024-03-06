defmodule Core.Task.Validators.Day do
  
  @spec valid(any()) :: Core.Shared.Types.Success.t() | Core.Shared.Types.Error.t()
  def valid(nil) do
    {:ok, true}
  end

  def valid(_) do
    {:error, "Невалидный день показа"}
  end
end