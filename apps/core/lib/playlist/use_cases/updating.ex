defmodule Core.Playlist.UseCases.Updating do
  
  alias Core.User.UseCases.Authorization

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error
  alias Core.Shared.Types.Exception

  @spec update(
    Core.User.Ports.Getter.t(),
    Core.Playlist.Ports.Getter.t(),
    Core.Playlist.Ports.Transformer.t(),
    map()
  ) :: Success.t() | Error.t() | Exception.t()
  def update(
    getter_user,
    getter_playlist,
    transformer_playlist, 
    args
  ) when is_atom(getter_user) and 
         is_atom(transformer_playlist) and 
         is_map(args) do
    with {:ok, user} <- Authorization.auth(getter_user, args),
         {:ok, true} <- Core.Shared.Validators.Identifier.valid(Map.get(args, :id)),
         {:ok, playlist} <- getter_playlist.get(UUID.string_to_binary!(args.id), user),
         {:ok, playlist} <- Core.Playlist.Editor.edit(playlist, args),
         {:ok, _} <- transformer_playlist.transform(playlist, user) do
      {:ok, true}
    else
      {:error, message} -> {:error, message}
      {:exception, message} -> {:exception, message}
    end
  end

  def update(_, _, _, _) do
    {:error, "Невалидные данные для обновления плэйлиста"}
  end
end