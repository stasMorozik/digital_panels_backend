defmodule Core.Playlist.UseCases.Creating do
  
  alias Core.User.UseCases.Authorization

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error
  alias Core.Shared.Types.Exception

  @spec create(
    Core.User.Ports.Getter.t(),
    Core.Content.Ports.GetterList.t(),
    Core.Playlist.Ports.Transformer.t(),
    map()
  ) :: Success.t() | Error.t() | Exception.t()
  def create(
    getter_user,
    getter_list_content,
    transformer_playlist, 
    args
  ) when is_atom(getter_user) and 
         is_atom(transformer_playlist) and 
         is_atom(getter_list_content) and
         is_map(args) do
    with {:ok, user} <- Authorization.auth(getter_user, args),
         {:ok, pagi} <- Core.Shared.Builders.Pagi.build(Map.get(args, :pagi, %{page: 1, limit: 10})),
         {:ok, filter} <- Core.Content.Builders.Filter.build(Map.get(args, :filter, %{})),
         {:ok, sort} <- Core.Content.Builders.Sort.build(Map.get(args, :sort, %{})),
         {:ok, contents} <- getter_list_content.get(pagi, filter, sort, user),
         {:ok, playlist} <- Core.Playlist.Builder.build(Map.put(args, :contents, contents)),
         {:ok, _} <- transformer_playlist.transform(playlist, user) do
      {:ok, true}
    else
      {:error, message} -> {:error, message}
      {:exception, message} -> {:exception, message}
    end
  end

  def create(_, _, _, _) do
    {:error, "Невалидные данные для создания плэйлиста"}
  end
end