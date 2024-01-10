defmodule Core.Schedule.Validators.Entry do
  
  @spec valid(any(), any()) :: Core.Shared.Types.Success.t() | Core.Shared.Types.Error.t()
  def valid({what_start, what_end} , {wherein_start, wherein_end}) 
    when is_integer(what_start) and 
         is_integer(what_end) and
         is_integer(wherein_start) and
         is_integer(wherein_end) do
    with false <- what_start >= wherein_start && what_start <= wherein_start,
         false <- what_end >= wherein_start && what_end <= wherein_end do
      {:ok, true}
    else
      true -> {:error, "Время показа на выбранный день уже занято"}
    end
  end

  def valid(_, _) do
    {:error, "Невалидные время начала и конца показа"}
  end
end