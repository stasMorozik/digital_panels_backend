defmodule Core.ConfirmationCode.UseCases.Creating do
  @moduledoc """
    Юзекейз создания кода подтверждения
  """

  alias Core.ConfirmationCode.Ports.Transformer
  alias Core.ConfirmationCode.Builder
  alias Core.Shared.Ports.Notifier
  alias Core.Shared.Validators.Email

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

  @spec create(
    Transformer.t(),
    Notifier.t(),
    binary()
  ) :: Success.t() | Error.t()
  def create(
    transformer_code_store,
    notifier,
    email
  ) when is_atom(transformer_code_store) and is_atom(notifier) do
    with true <- Kernel.function_exported?(transformer_code_store, :transform, 1),
         true <- Kernel.function_exported?(notifier, :notify, 1),
         {:ok, entity} <- Builder.build(email, Email),
         {:ok, _} <- transformer_code_store.transform(entity),
         {:ok, _}
            <- notifier.notify(%{
              to: email,
              from: "system_content_manager@dev.org",
              subject: "Confirm email address",
              message: "Confirmation code #{entity.code}"
            }) do
      Success.new(true)
    else
      {:error, error} -> {:error, error}
      false -> Error.new("Не валидные аргументы для создания кода подтверждения")
    end
  end

  def create(_, _, _) do
    Error.new("Не валидные аргументы для создания кода подтверждения")
  end
end
