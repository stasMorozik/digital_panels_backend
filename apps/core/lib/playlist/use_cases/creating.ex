defmodule Core.Playlist.UseCases.Creating do
  @moduledoc """
    Юзекейз создания плэйлиста
  """
  
  alias Core.Playlist.Builder
  alias Core.Playlist.Ports.Transformer

  alias Core.User.UseCases.Authorization
  alias User.Ports.Getter, as: GetterUser

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

  @spec create(
    Authorization.t(),
    GetterUser.t(),
    Transformer.t(),
    map()
  ) :: Success.t() | Error.t()
  def create(
    authorization_use_case,
    getter_user,
    transformer,
    args
  ) when is_atom(authorization_use_case)
    and is_atom(transformer)
    and is_map(args) do
      with true <- Kernel.function_exported?(authorization_use_case, :auth, 2),
           true <- Kernel.function_exported?(transformer, :transform, 2),
           {:ok, user} <- authorization_use_case.auth(getter_user, args),
           {:ok, playlist} <- Builder.build(%{
              name: Map.get(args, :name, ""),
              contents: Map.get(args, :contents, []),
              web_dav_url: Map.get(args, :web_dav_url, "")
           }),
           {:ok, _} <- transformer.transform(playlist, user) do
        Success.new(true)
      else
        false -> Error.new("Не валидные аргументы для создания плэйлиста")
        {:error, message} -> {:error, message}
      end
  end

  def create(_, _, _, _) do
    Error.new("Не валидные аргументы для создания плэйлиста")
  end
end