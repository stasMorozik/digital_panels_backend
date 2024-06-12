defmodule Core.Task.Validators.TypeDay do
  
  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

  @types %{
    "Каждый день": Core.Task.Validators.Day,
    "Каждый день недели": Core.Task.Validators.WeekDay,
    "Каждый день месяца": Core.Task.Validators.MonthDay,
    "Определенное число": Core.Task.Validators.Date,
  }

  @spec valid(tuple()) :: Success.t() | Error.t()
  def valid({type, day}) do
    with {:ok, true} <- Core.Task.Validators.Type.valid(type),
         module <- Map.get(@types, String.to_existing_atom(type)),
         {:ok, true} <- module.valid(day) do
      {:ok, true}
    else
      {:error, message} -> {:error, message}
    end
  end
end