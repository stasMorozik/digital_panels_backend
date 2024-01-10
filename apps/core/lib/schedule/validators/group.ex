defmodule Core.Schedule.Validators.Group do
  
  @spec valid(any()) :: Core.Shared.Types.Success.t() | Core.Shared.Types.Error.t()
  def valid(%Core.Group.Entity{} = _group) do
    {:ok, true}
  end

  def valid(_) do
    {:error, "Невалидная группа"}
  end
end