defmodule Core.File.UseCases.Getting do
  
  alias Core.User.UseCases.Authorization

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error
  alias Core.Shared.Types.Exception

  @spec get(
    Core.User.Ports.Getter.t(),
    Core.File.Ports.Getter.t(),
    map()
  ) :: Success.t() | Error.t() | Exception.t()
  def get(
    getter_user,
    getter_file,
    args
  ) when is_atom(getter_user) and
         is_atom(getter_file) and
         is_map(args) do

    {result, _} = UUID.info(Map.get(args, :id))

    with :ok <- result,
         {:ok, user} <- Authorization.auth(getter_user, args),
         {:ok, file} <- getter_file.get(UUID.string_to_binary!(args.id), user) do
      {:ok, file}
    else
      :error -> {:error, "Не валидный UUID файла"}
      {:error, message} -> {:error, message}
      {:exception, message} -> {:exception, message}
    end
  end

  def get(_, _, _) do
    {:error, "Невалидные данные для получения файла"}
  end
end