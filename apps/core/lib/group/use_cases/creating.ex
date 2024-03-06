defmodule Core.Group.UseCases.Creating do

  alias Core.User.UseCases.Authorization

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error
  alias Core.Shared.Types.Exception

  @spec create(
    Core.User.Ports.Getter.t(),
    Core.Group.Ports.Transformer.t(),
    map()
  ) :: Success.t() | Error.t() | Exception.t()
  def create(
    getter_user,
    transformer_group, 
    args
  ) when is_atom(getter_user) and 
         is_atom(transformer_group) and 
         is_map(args) do
    with {:ok, user} <- Authorization.auth(getter_user, args),
         {:ok, group} <- Core.Group.Builder.build(args),
         {:ok, _} <- transformer_group.transform(group, user) do
      {:ok, true}
    else
      {:error, message} -> {:error, message}
      {:exception, message} -> {:exception, message}
    end
  end

  def create(_, _, _) do
    {:error, "Невалидные данные для создания группы"}
  end
end