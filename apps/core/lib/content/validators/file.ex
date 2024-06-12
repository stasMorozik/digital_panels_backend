defmodule Core.Content.Validators.File do
  
  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

  @spec valid(any()) :: Success.t() | Error.t()
  def valid(%Core.File.Entity{} = _file) do    
    {:ok, true}
  end

  def valid(_) do    
    {:error, "Не валидный файл"}
  end
end