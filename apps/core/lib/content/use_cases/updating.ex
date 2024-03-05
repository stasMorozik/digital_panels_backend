defmodule Core.Content.UseCases.Updating do
  
  alias Core.User.UseCases.Authorization

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error
  alias Core.Shared.Types.Exception
  alias Core.Shared.Validators.Identifier

  @spec update(
    Core.User.Ports.Getter.t(),
    Core.Playlist.Ports.Getter.t(),
    Core.Content.Ports.Getter.t(),
    Core.File.Ports.Getter.t(),
    Core.Content.Ports.Transformer.t(),
    map()
  ) :: Success.t() | Error.t() | Exception.t()
  def update(
    getter_user,
    getter_playlist,
    getter_content,
    getter_file, 
    transformer_content, 
    args
  ) when is_atom(getter_user) and 
         is_atom(getter_playlist) and 
         is_atom(getter_content) and
         is_atom(getter_file) and
         is_atom(transformer_content) and 
         is_map(args) do
    with {:ok, user} <- Authorization.auth(getter_user, args),
         id <- Map.get(args, :id),
         file_id <- Map.get(args, :file_id),
         playlist_id <- Map.get(args, :playlist_id),
         {:ok, true} <- Identifier.valid(id),
         {:ok, true} <- Identifier.valid(file_id),
         {:ok, true} <- Identifier.valid(playlist_id),
         {:ok, content} <- getter_content.get(id, user),
         {:ok, file} <- getter_file.get(file_id, user),
         {:ok, playlist} <- getter_playlist.get(playlist_id, user),
         args <- Map.put(args, :file, case args.file_id == file.id do 
            true -> nil
            false -> file
         end),
         args <- Map.put(args, :playlist, case playlist.id == content.playlist.id do 
            true -> nil
            false -> playlist
         end),
         {:ok, content} <- Core.Content.Editor.edit(content, args),
         {:ok, _} <- transformer_content.transform(content, user) do
      {:ok, true}
    else
      {:error, message} -> {:error, message}
      {:exception, message} -> {:exception, message}
    end
  end

  def update(_, _, _, _, _, _) do
    {:error, "Невалидные данные для редактирования контента"}
  end
end