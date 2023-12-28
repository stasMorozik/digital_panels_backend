defmodule Core.Device.Validators.Description do
  @moduledoc """
    Валидирует опсание устройства
  """

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error
  
  @min_length 3
  @max_length 512

  @spec valid(any()) :: Success.t() | Error.t()
  def valid(desc) when is_binary(desc) do
    with true <- String.length(desc) >= @min_length,
         true <- String.length(desc) <= @max_length do
      {:ok, true}
    else
      false -> {:error, "Невалидное описание"}
    end
  end

  def valid(_) do
    {:error, "Невалидное описание"}
  end
end