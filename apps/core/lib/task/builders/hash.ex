defmodule Core.Task.Builders.Hash do

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

  @types %{
    "Каждый день": Core.Task.Validators.Day,
    "Каждый день недели": Core.Task.Validators.WeekDay,
    "Каждый день месяца": Core.Task.Validators.MonthDay,
    "Определенное число": Core.Task.Validators.Date,
  }

  @spec build(Success.t() | Error.t(), any(), any()) :: Success.t() | Error.t()
  def build({:ok, entity}, type, day) do
    with {:ok, true} <- Core.Task.Validators.Type.valid(type),
         module <- Map.get(@types, String.to_existing_atom(type)),
         {:ok, true} <- module.valid(day) do
      {:ok, Map.put(entity, :hash, Base.encode64("#{type}#{day}", padding: false))}
    else
      {:error, message} -> {:error, message}
    end
  end

  def build({:error, message}, _, _) do
    {:error, message}
  end
end