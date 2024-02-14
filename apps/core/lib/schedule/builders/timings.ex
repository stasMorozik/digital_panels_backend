defmodule Core.Schedule.Builders.Timings do
  
  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

  @spec build(Success.t() | Error.t(), any()) :: Success.t() | Error.t()
  def build({:ok, entity}, timings) do
    with {:ok, true} <- Core.Schedule.Validators.Timings.valid(timings),
         {:ok, timings} <- build(timings, [], %{}) do
      {:ok, Map.put(entity, :timings, timings)}
    else
      {:error, message} -> {:error, message}
    end
  end

  def build({:error, message}, _) do
    {:error, message}
  end

  defp build([head | tail], acc_list, acc_hash) do
    with {:ok, new_timing} <- Core.Schedule.Builders.Timing.build(head),
         type <- new_timing.type,
         day <- to_string(new_timing.day),
         hash <- Base.encode64("#{type}#{day}", padding: false),
         timing <- Map.get(acc_hash, hash) do
      case timing == nil do
        true ->
          build(tail, [new_timing | acc_list], Map.put(acc_hash, hash, new_timing))
        false ->
          args_0 = {new_timing.start, new_timing.end}
          args_1 = {timing.start, timing.end}
          case Core.Schedule.Validators.Entry.valid(args_0, args_1) do
            {:ok, true} -> build(tail, [new_timing | acc_list], Map.put(acc_hash, hash, new_timing))
            {:error, message} -> {:error, message}
          end
      end
    else
      {:error, message} -> {:error, message}
    end
  end

  defp build([], acc_list, _acc_hash) do
    {:ok, acc_list}
  end
end