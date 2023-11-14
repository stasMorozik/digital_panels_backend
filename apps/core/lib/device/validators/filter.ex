defmodule Core.Device.Validators.Filter do
  @moduledoc """
    Валидирует параметры фильтрации для получения списка
  """

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

  @spec valid(map()) :: Success.t() | Error.t()
  def valid(args) when is_map(args) do

  end

  def valid(_) do
    
  end
end