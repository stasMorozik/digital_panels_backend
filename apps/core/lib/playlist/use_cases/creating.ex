defmodule Core.Playlist.UseCases.Creating do
  @moduledoc """
    Юзекейз создания плэйлиста
  """
  
  alias Core.Playlist.Builder
  alias Core.Playlist.Ports.Transformer, as: PlaylistTransformer
  alias Core.File.Ports.Transformer, as: FileTransformer

  alias Core.User.UseCases.Authorization
  alias User.Ports.Getter, as: GetterUser

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error
  alias Core.Shared.Types.Exception

  @spec create(
    Authorization.t(),
    GetterUser.t(),
    FileTransformer.t(),
    PlaylistTransformer.t(),
    map()
  ) :: Success.t() | Error.t() | Exception.t()
  def create(
    authorization_use_case,
    getter_user,
    file_transformer,
    playlist_transformer,
    args
  ) when is_atom(authorization_use_case)
    and is_atom(file_transformer)
    and is_atom(playlist_transformer)
    and is_map(args) do
      with {:ok, user} <- authorization_use_case.auth(getter_user, args),
           {:ok, playlist} <- Builder.build(args),
           fun <- fn (content) -> file_transformer.transform(content.file, user) end,
           list_results <- Enum.map(playlist.contents, fun),
           fun <- fn (tuple) -> elem(tuple, 0) == :error end,
           nil <- Enum.find(list_results, fun),
           {:ok, _} <- playlist_transformer.transform(playlist, user) do
        Success.new(true)
      else
        {:error, message} -> {:error, message}
        {:exception, message} -> {:exception, message}
      end
  end

  def create(_, _, _, _, _) do
    Error.new("Не валидные аргументы для создания плэйлиста")
  end
end