defmodule Core.Schedule.Builders.Timings do
  
  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

  @spec build(Success.t() | Error.t(), any()) :: Success.t() | Error.t()
  def build({:ok, entity}, timings) do
    with {:ok, true} <- Core.Schedule.Validators.Timings.valid(timings),
         {:ok, timings} <- build(timings, [], :ok) do
      {:ok, Map.put(entity, :timings, timings)}
    else
      {:error, message} -> {:error, message}
    end
  end

  def build({:error, message}, _) do
    {:error, message}
  end

  defp build([head | tail], acc_list, rest) do
    case Core.Schedule.Builders.Timing.build(head) do
      {:ok, timing} -> build(tail, [timing | acc_list], rest)
      {:error, message} -> {:error, message}
    end
  end

  defp build([], acc_list, rest) do
    {rest, acc_list}
  end
end