defmodule Core.Task.Builders.Hash do

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

  @types %{
    "Каждый день": Core.Task.Validators.Day,
    "Каждый день недели": Core.Task.Validators.WeekDay,
    "Каждый день месяца": Core.Task.Validators.MonthDay,
    "Определенное число": Core.Task.Validators.Date,
  }

  @spec build(Success.t() | Error.t(), tuple()) :: Success.t() | Error.t()
  def build({:ok, entity}, {type, day, end_hour, end_minute}) do
    with fun_0 <- fn (hour) ->
            case hour == 24 do
              true -> 0
              false -> hour
            end
         end,
         fun_1 <- fn (sum) ->
            cond do 
              sum <= 240 -> 1
              sum <= 480 -> 2
              sum <= 720 -> 3
              sum <= 960 -> 4
              sum <= 1200 -> 5
              sum <= 1440 -> 6
            end
         end,
         {:ok, true} <- Core.Task.Validators.Type.valid(type),
         module <- Map.get(@types, String.to_existing_atom(type)),
         {:ok, true} <- module.valid(day),
         end_hour <- fun_0.(end_hour),
         sum_end <- (end_hour * 60) + end_minute,
         quarter <- fun_1.(sum_end) do
      {:ok, Map.put(entity, :hash, Base.encode64("#{type}#{day}#{quarter}", padding: false))}
    else
      {:error, message} -> {:error, message}
    end
  end

  def build({:error, message}, _) do
    {:error, message}
  end
end