defmodule Core.Task.Builders.Playlist do
  
  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

  @spec build(Success.t() | Error.t(), any()) :: Success.t() | Error.t()
  def build({:ok, entity}, playlist) do
    case Core.Task.Validators.Playlist.valid(playlist) do
      {:ok, _} -> {:ok, Map.put(entity, :playlist, playlist)}
      {:error, message} -> {:error, message}
    end
  end

  def build({:error, message}, _) do
    {:error, message}
  end
end