defmodule Core.Task.Validators.Sum do
  
  @spec valid(any(), any()) :: Core.Shared.Types.Success.t() | Core.Shared.Types.Error.t()
  def valid(sum_start, sum_end) when is_integer(sum_end) and is_integer(sum_end) do
    case sum_end > sum_start do
      true -> {:ok, true}
      false -> {:error, "Невалидные время начала и конца показа"}
    end
  end

  def valid(_, _) do
    {:error, "Невалидные время начала и конца показа"}
  end
end