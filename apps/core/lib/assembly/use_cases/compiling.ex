defmodule Core.Assembly.UseCases.Compiling do

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error
  alias Core.Shared.Types.Exception

  @spec compile(
    Core.Assembly.Ports.Getter.t(),
    Core.Assembly.Ports.Transformer.t(),
    Core.Assembly.Ports.Transformer.t(),
    Core.Assembly.Ports.Transformer.t(),
    map()
  ) :: Success.t() | Error.t() | Exception.t()
  def compile(
    getter_assembly,
    transformer_assembly_0,
    transformer_assembly_1,
    args
  ) when is_atom(getter_assembly) and
         is_atom(transformer_assembly_0) and
         is_atom(transformer_assembly_1) and
         is_map(args) do
    with id <- Map.get(args, :id),
         {:ok, true} <- Core.Shared.Validators.Identifier.valid(id),
         user <- Map.get(args, :user),  
         {:ok, assembly} <- getter_assembly.get(id, user),
         {:ok, assembly} <- Core.Assembly.Editor.edit(assembly),
         {:ok, true} <- transformer_assembly_0.transform(assembly, user),
         {:ok, true} <- transformer_assembly_1.transform(assembly, user) do
      {:ok, true}
    else
      {:error, message} -> {:error, message}
      {:exception, message} -> {:exception, message}
    end
  end

  def compile(_, _, _, _, _) do
    {:error, "Невалидные данные для обновления сборки"}
  end
end