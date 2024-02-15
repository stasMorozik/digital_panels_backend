defmodule Core.Group.UseCases.Updating do
  
  alias Core.User.UseCases.Authorization

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error
  alias Core.Shared.Types.Exception

  @spec update(
    Core.User.Ports.Getter.t(),
    Core.Group.Ports.Getter.t(),
    Core.Group.Ports.Transformer.t(),
    map()
  ) :: Success.t() | Error.t() | Exception.t()
  def update(
    getter_user,
    getter_group,
    transformer_group, 
    args
  ) when is_atom(getter_user) and
         is_atom(getter_group) and
         is_atom(transformer_group) and
         is_map(args) do
    
    {result, _} = UUID.info(Map.get(args, :id))

    with :ok <- result,
         {:ok, user} <- Authorization.auth(getter_user, args),
         {:ok, group} <- getter_group.get(UUID.string_to_binary!(args.id), user),
         {:ok, group} <- Core.Group.Editor.edit(group, args),
         {:ok, _} <- transformer_group.transform(group, user) do
      {:ok, true}
    else
      :error -> {:error, "Не валидный UUID группы"}
      {:error, message} -> {:error, message}
      {:exception, message} -> {:exception, message}
    end
  end

  def update(_, _, _, _) do
    {:error, "Невалидные данные для обновления группы"}
  end
end