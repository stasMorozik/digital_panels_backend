defmodule Core.User.UseCases.Registration do
  @moduledoc """
    Юзекейз регистрации пользователя
  """

  alias Core.User.Ports.Transformer
  alias Core.User.Builder
  alias Core.Shared.Ports.Notifier
  alias Core.ConfirmationCode.Ports.Getter
  alias Core.ConfirmationCode.Methods.Confirming

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error
  alias Core.Shared.Types.Exception

  @from Application.compile_env(:core, :email_address, "digital_panels@dev.org")

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
    with {:ok, code_entity} <- getter_confiramtion_code.get(Map.get(args, :email)),
         {:ok, _} <- Confirming.confirm(code_entity, Map.get(args, :code)),
         {:ok, user_entity} <- Builder.build(args),
         {:ok, _} <- transformer_users_store.transform(user_entity),
         {:ok, _}
            <- notifier.notify(%Core.Shared.Types.Notification{
              to: Map.get(args, :email),
              from: @from,
              subject: "Добро пожаловать",
              message: "Рады приветствовать вас #{Map.get(args, :name)}"
            }) do

      {:ok, true}
      
    else
      {:error, error} -> {:error, error}
      {:exception, error} -> {:exception, error}
    end
  end

  def reg(_, _, _, _) do
    {:error, "Не валидные аргументы для регистрации пользователя"}
  end
end
