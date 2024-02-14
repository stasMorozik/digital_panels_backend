defmodule Core.Content.UseCases.Updating do
  
  alias Core.User.UseCases.Authorization

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error
  alias Core.Shared.Types.Exception

  @spec update(
    Core.User.Ports.Getter.t(),
    Core.Content.Ports.Getter.t(),
    Core.File.Ports.Getter.t(),
    Core.Content.Ports.Transformer.t(),
    map()
  ) :: Success.t() | Error.t() | Exception.t()
  def update(
    getter_user,
    getter_content,
    getter_file, 
    transformer_content, 
    args
  ) when is_atom(getter_user) and 
         is_atom(getter_content) and
         is_atom(getter_file) and
         is_atom(transformer_content) and 
         is_map(args) do

    {result_0, _} = UUID.info(Map.get(args, :id))
    {result_1, _} = UUID.info(Map.get(args, :file_id))
    
    with :ok <- result_0,
         :ok <- result_1,
         {:ok, user} <- Authorization.auth(getter_user, args),
         {:ok, content} <- getter_content.get(UUID.string_to_binary!(args.id), user),
         {:ok, file} <- getter_file.get(UUID.string_to_binary!(args.file_id), user),
         args <- Map.put(args, :file, case args.file_id == file.id do 
            true -> nil
            false -> file
         end),
         {:ok, content} <- Core.Content.Editor.edit(content, Map.put(args, :file, file)),
         {:ok, _} <- transformer_content.transform(content, user) do
      {:ok, true}
    else
      :error -> {:error, "Не валидный UUID файла/контента"}
      {:error, message} -> {:error, message}
      {:exception, message} -> {:exception, message}
    end
  end

  def update(_, _, _, _, _) do
    {:error, "Невалидные данные для редактирования контента"}
  end
end