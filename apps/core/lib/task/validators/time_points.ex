defmodule Core.Task.Validators.TimePoints do
  
  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

  @spec valid(tuple()) :: Success.t() | Error.t()
  def valid({hour, minute}) do
    with {:ok, true} <- Core.Task.Validators.Hour.valid(hour),
         {:ok, true} <- Core.Task.Validators.Minute.valid(minute) do
      {:ok, true}
    else
      {:error, message} -> {:error, message}
    end
  end
end