defmodule Core.Schedule.Validators.Day do
  
  @spec valid(any()) :: Core.Shared.Types.Success.t() | Core.Shared.Types.Error.t()
  def valid(nil) do
    {:ok, true}
  end

  def valid(_) do
    {:error, "Невалидный день для тайминга"}
  end
end