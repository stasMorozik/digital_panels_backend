defmodule Core.Assembly.UseCases.Creating do
  
  alias Core.User.UseCases.Authorization

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error
  alias Core.Shared.Types.Exception

  @spec create(
    Core.User.Ports.Getter.t(),
    Core.Assembly.Ports.Transformer.t(),
    map()
  ) :: Success.t() | Error.t() | Exception.t()
  def create(
    getter_user, 
    transformer_assembly,
    args
  ) when is_atom(getter_user) and
         is_atom(transformer_assembly) and
         is_map(args) do
    with {:ok, user} <- Authorization.auth(getter_user, args),
         {:ok, assembly} <- Core.Assembly.Builder.build(args),
         {:ok, true} <- transformer_assembly.transform(assembly, user) do
      {:ok, true}
    else
      {:error, message} -> {:error, message}
      {:exception, message} -> {:exception, message}
    end
  end

  def create(_, _, _) do
    {:error, "Невалидные данные для создания сборки"}
  end
end