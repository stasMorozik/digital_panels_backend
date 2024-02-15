defmodule Core.Content.UseCases.Creating do
  
  alias Core.User.UseCases.Authorization

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error
  alias Core.Shared.Types.Exception

  @spec create(
    Core.User.Ports.Getter.t(),
    Core.Playlist.Ports.Getter.t(),
    Core.File.Ports.Getter.t(),
    Core.Content.Ports.Transformer.t(),
    map()
  ) :: Success.t() | Error.t() | Exception.t()
  def create(
    getter_user,
    getter_playlist,
    getter_file, 
    transformer_content, 
    args
  ) when is_atom(getter_user) and
         is_atom(getter_playlist) and 
         is_atom(getter_file) and
         is_atom(transformer_content) and 
         is_map(args) do
    with {:ok, user} <- Authorization.auth(getter_user, args),
         {:ok, true} <- Core.Shared.Validators.Identifier.valid(Map.get(args, :file_id)),
         {:ok, true} <- Core.Shared.Validators.Identifier.valid(Map.get(args, :playlist_id)),
         {:ok, file} <- getter_file.get(UUID.string_to_binary!(args.file_id), user),
         {:ok, playlist} <- getter_playlist.get(UUID.string_to_binary!(args.playlist_id), user),
         {:ok, playlist} <- Core.Playlist.Editor.edit(playlist, %{sum: playlist.sum + 1}),
         args <- Map.put(args, :file, file),
         args <- Map.put(args, :playlist, playlist),
         {:ok, content} <- Core.Content.Builder.build(args),
         {:ok, true} <- transformer_content.transform(content, user) do
      {:ok, true}
    else
      {:error, message} -> {:error, message}
      {:exception, message} -> {:exception, message}
    end
  end

  def create(_, _, _, _, _) do
    {:error, "Невалидные данные для создания контента"}
  end
end