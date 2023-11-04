defmodule Core.Playlist.UseCases.Creating do
  @moduledoc """
    Юзекейз редактирования плэйлиста
  """
  
  alias Core.Playlist.Builder
  alias Core.Playlist.Ports.Transformer, as: PlaylistTransformer
  alias Core.File.Ports.Transformer, as: FileTransformer
  alias Core.Playlist.Ports.Getter, as: GetterPlaylist

  alias Core.User.UseCases.Authorization
  alias User.Ports.Getter, as: GetterUser

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error
  alias Core.Shared.Types.Exception

  alias Core.Playlist.Methods.Edit

  @spec create(
    Authorization.t(),
    GetterUser.t(),
    GetterPlaylist.t(),
    FileTransformer.t(),
    PlaylistTransformer.t(),
    map()
  ) :: Success.t() | Error.t() | Exception.t()
  def create(
    authorization_use_case,
    getter_user,
    getter_playlist,
    file_transformer,
    playlist_transformer,
    args
  ) when is_atom(authorization_use_case)
    and is_atom(getter_playlist)
    and is_atom(file_transformer)
    and is_atom(playlist_transformer)
    and is_map(args) do

      {result, _} = UUID.info(Map.get(args, :id))

      with true <- Kernel.function_exported?(authorization_use_case, :auth, 2),
           true <- Kernel.function_exported?(playlist_transformer, :transform, 2),
           true <- Kernel.function_exported?(file_transformer, :transform, 2),
           true <- Kernel.function_exported?(getter_playlist, :transform, 1),
           :ok <- result,
           {:ok, user} <- authorization_use_case.auth(getter_user, args),
           {:ok, playlist} <- getter.get(UUID.string_to_binary!(args.id)),
           default_args <- %{
              name: Map.get(args, :name),
              contents: Map.get(args, :contents)
              web_dav_url: Map.get(args, :web_dav_url, "")
           },
           {:ok, edited_playlist} <- Edit.edit(playlist, default_args),
           {:ok, _} <- transform_file_storage(
              file_transformer, 
              edited_playlist.contents, 
              user
           ),
           {:ok, _} <- playlist_transformer.transform(playlist, user) do
        Success.new(true)
      else
        false -> Error.new("Не валидные аргументы для создания плэйлиста")
        :error -> Error.new("Не валидный UUID плэйлиста: #{Map.get(args, :id)}")
        {:error, message} -> {:error, message}
        {:exception, message} -> {:exception, message}
      end
  end

  def create(_, _, _, _, _, _) do
    Error.new("Не валидные аргументы для создания плэйлиста")
  end

  defp transform_file_storage(file_transformer, contents, user) do
    list_results = Enum.map(contents, fn c -> file_transformer.transform(c.file, user) end)

    maybe_error = Enum.find(list_results, fn tuple -> elem(tuple, 0) == :error end)

    case maybe_error do
      nil -> Success.new(true)
      error -> error
    end
  end
end