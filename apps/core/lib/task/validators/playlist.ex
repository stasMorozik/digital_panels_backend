defmodule Core.Task.Validators.Playlist do
  
  @spec valid(any()) :: Core.Shared.Types.Success.t() | Core.Shared.Types.Error.t()
  def valid(%Core.Playlist.Entity{} = _playlist) do
    {:ok, true}
  end

  def valid(_) do
    {:error, "Невалидный плэйлист"}
  end
end