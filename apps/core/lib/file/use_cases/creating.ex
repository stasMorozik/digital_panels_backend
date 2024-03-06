defmodule Core.File.UseCases.Creating do
  
  alias Core.User.UseCases.Authorization

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error
  alias Core.Shared.Types.Exception

  @spec create(
    Core.User.Ports.Getter.t(),
    Core.File.Ports.Transformer.t(),
    Core.File.Ports.Transformer.t(),
    map()
  ) :: Success.t() | Error.t() | Exception.t()
  def create(
    getter_user, 
    transformer_file_0,
    transformer_file_1,
    args
  ) when is_atom(getter_user) and
         is_atom(transformer_file_0) and
         is_atom(transformer_file_1) and
         is_map(args) do
    with {:ok, user} <- Authorization.auth(getter_user, args),
         {:ok, file} <- Core.File.Builder.build(args),
         {:ok, true} <- transformer_file_0.transform(file, user),
         {:ok, true} <- transformer_file_1.transform(file, user) do
      {:ok, true}
    else
      {:error, message} -> {:error, message}
      {:exception, message} -> {:exception, message}
    end
  end

  def create(_, _, _) do
    {:error, "Невалидные данные для создания файла"}
  end
end