defmodule Core.Assembly.UseCases.Updating do
  
  alias Core.User.UseCases.Authorization

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error
  alias Core.Shared.Types.Exception

  @spec update(
    Core.User.Ports.Getter.t(),
    Core.Assembly.Ports.Getter.t(),
    Core.Assembly.Ports.Transformer.t(),
    map()
  ) :: Success.t() | Error.t() | Exception.t()
  def update(
    getter_user,
    getter_assembly,
    transformer_assembly, 
    args
  ) when is_atom(getter_user) and
         is_atom(getter_assembly) and
         is_atom(transformer_assembly) and
         is_map(args) do
    with {:ok, user} <- Authorization.auth(getter_user, args),
         {:ok, true} <- Core.Shared.Validators.Identifier.valid(Map.get(args, :id)),
         {:ok, assembly} <- getter_assembly.get(args.id, user),
         {:ok, assembly} <- Core.Assembly.Editor.edit(assembly),
         {:ok, true} <- transformer_assembly.transform(assembly, user) do
      {:ok, true}
    else
      {:error, message} -> {:error, message}
      {:exception, message} -> {:exception, message}
    end
  end

  def update(_, _, _, _) do
    {:error, "Невалидные данные для обновления сборки"}
  end
end