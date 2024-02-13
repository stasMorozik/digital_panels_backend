defmodule Core.Content.UseCases.Creating do
  
  alias Core.User.UseCases.Authorization

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error
  alias Core.Shared.Types.Exception

  @spec create(
    Core.User.Ports.Getter.t(),
    Core.File.Ports.Getter.t(),
    Core.Content.Ports.Transformer.t(),
    map()
  ) :: Success.t() | Error.t() | Exception.t()
  def create(
    getter_user,
    getter_file, 
    transformer_content, 
    args
  ) when is_atom(getter_user) and 
         is_atom(getter_file) and
         is_atom(transformer_content) and 
         is_map(args) do

    {result, _} = UUID.info(Map.get(args, :file_id))
    
    with :ok <- result,
         {:ok, user} <- Authorization.auth(getter_user, args),
         {:ok, file} <- getter_file.get(UUID.string_to_binary!(args.file_id), user),
         {:ok, content} <- Core.Content.Builder.build(Map.put(args, :file, file)),
         {:ok, _} <- transformer_content.transform(content, user) do
      {:ok, true}
    else
      :error -> {:error, "Не валидный UUID файла"}
      {:error, message} -> {:error, message}
      {:exception, message} -> {:exception, message}
    end
  end

  def create(_, _, _, _) do
    {:error, "Невалидные данные для создания контента"}
  end
end