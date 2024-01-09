defmodule Core.Playlist.Builders.Contents do
  
  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

  @spec build(Success.t() | Error.t(), any()) :: Success.t() | Error.t()
  def build({:ok, entity}, contents) do
    case Core.Playlist.Validators.Contents.valid(contents) do
      {:ok, true} -> {:ok, Map.put(entity, :contents, contents)}
      {:error, message} -> {:error, message}  
    end
  end

  def build({:error, message}, _) do
    {:error, message}
  end
end