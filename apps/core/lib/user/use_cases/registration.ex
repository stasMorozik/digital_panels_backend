defmodule Core.User.UseCases.Registration do
  @moduledoc """
    Юзекейз регистрации пользователя
  """

  alias Core.User.Ports.Transformer
  alias Core.User.Builder
  alias Core.Shared.Ports.Notifier
  alias Core.ConfirmationCode.Ports.Getter
  alias Core.ConfirmationCode.Methods.CheckerHasConfirmation

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error
  alias Core.Shared.Types.Exception

  @spec reg(
    Transformer.t(),
    Getter.t(),
    Notifier.t(),
    map()
  ) :: Success.t() | Error.t() | Exception.t()
  def reg(
    transformer_users_store,
    getter_confiramtion_code,
    notifier,
    args
  ) when is_atom(transformer_users_store)
    and is_atom(getter_confiramtion_code)
    and is_atom(notifier)
    and is_map(args) do
    with true <- Kernel.function_exported?(transformer_users_store, :transform, 1),
         true <- Kernel.function_exported?(getter_confiramtion_code, :get, 1),
         true <- Kernel.function_exported?(notifier, :notify, 1),
         {:ok, code_entity} <- getter_confiramtion_code.get(Map.get(args, :email)),
         {:ok, _} <- CheckerHasConfirmation.has(code_entity),
         {:ok, user_entity} <- Builder.build(args),
         {:ok, _} <- transformer_users_store.transform(user_entity),
         {:ok, _}
            <- notifier.notify(%{
              to: Map.get(args, :email),
              from: "system_content_manager@dev.org",
              subject: "Welcome",
              message: "Hello #{Map.get(args, :name)}"
            }) do
      Success.new(true)
    else
      {:error, error} -> {:error, error}
      {:exception, error} -> {:exception, error}
      false -> Error.new("Не валидные аргументы для регистрации пользователя")
    end
  end

  def reg(_, _, _, _) do
    Error.new("Не валидные аргументы для регистрации пользователя")
  end
end
