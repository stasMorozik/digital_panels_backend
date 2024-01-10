defmodule Core.Schedule.Builders.Day do
  
  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

  @types %{
    "Каждый день": Core.Schedule.Validators.Day,
    "Каждый день недели": Core.Schedule.Validators.WeekDay,
    "Каждый день месяца": Core.Schedule.Validators.MonthDay,
    "Определенное число": Core.Schedule.Validators.Date,
  }


  @spec build(Success.t() | Error.t(), any(), any()) :: Success.t() | Error.t()
  def build({:ok, entity}, type, day) do
    with {:ok, true} <- Core.Schedule.Validators.Type.valid(type),
         module <- Map.get(@types, String.to_atom(type)),
         module.valid(day) do
      {:ok, Map.put(entity, :day, day)}
    else
      {:error, message} -> {:error, message}
    end
  end

  def build({:error, message}, _, _) do
    {:error, message}
  end
end