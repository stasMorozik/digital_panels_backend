defmodule Core.Playlist.UseCases.Updating do
  
  alias Core.User.UseCases.Authorization

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error
  alias Core.Shared.Types.Exception

  @spec update(
    Core.User.Ports.Getter.t(),
    Core.Playlist.Ports.Getter.t(),
    Core.Content.Ports.GetterList.t(),
    Core.Playlist.Ports.Transformer.t(),
    map()
  ) :: Success.t() | Error.t() | Exception.t()
  def update(
    getter_user,
    getter_playlist,
    getter_list_content,
    transformer_playlist, 
    args
  ) when is_atom(getter_user) and 
         is_atom(transformer_playlist) and 
         is_atom(getter_list_content) and
         is_map(args) do

    {result, _} = UUID.info(Map.get(args, :id))

    with :ok <- result,
         {:ok, user} <- Authorization.auth(getter_user, args),
         {:ok, playlist} <- getter_playlist.get(UUID.string_to_binary!(args.id), user),
         {:ok, pagi} <- Core.Shared.Builders.Pagi.build(Map.get(args, :pagi, %{page: 1, limit: 10})),
         {:ok, filter} <- Core.Content.Builders.Filter.build(Map.get(args, :filter, %{})),
         {:ok, sort} <- Core.Content.Builders.Sort.build(Map.get(args, :sort, %{})),
         {:ok, contents} <- getter_list_content.get(pagi, filter, sort, user),
         {:ok, playlist} <- Core.Playlist.Editor.edit(playlist, Map.put(args, :contents, contents)),
         {:ok, _} <- transformer_playlist.transform(playlist, user) do
      {:ok, true}
    else
      :error -> {:error, "Не валидный UUID плэйлиста"}
      {:error, message} -> {:error, message}
      {:exception, message} -> {:exception, message}
    end
  end

  def update(_, _, _, _) do
    {:error, "Невалидные данные для обновления плэйлиста"}
  end
end