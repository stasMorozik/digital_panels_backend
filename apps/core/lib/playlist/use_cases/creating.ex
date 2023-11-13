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
           {:ok, playlist} <- Builder.build(%{
              name: Map.get(args, :name, ""),
              contents: Map.get(args, :contents, []),
              web_dav_url: Map.get(args, :web_dav_url, "")
           }),
           {:ok, _} <- transform_file_storage(
              file_transformer, 
              playlist.contents, 
              user
           ),
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

  defp transform_file_storage(file_transformer, contents, user) do
    list_results = Enum.map(contents, fn c -> file_transformer.transform(c.file, user) end)

    maybe_error = Enum.find(list_results, fn tuple -> elem(tuple, 0) == :error end)

    case maybe_error do
      nil -> Success.new(true)
      error -> error
    end
  end
end