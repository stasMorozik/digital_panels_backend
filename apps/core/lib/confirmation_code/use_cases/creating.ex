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
  alias Core.Shared.Types.Exception

  @from Application.compile_env(:core, :email_address, "digital_panels@dev.org")

  @spec create(
    Transformer.t(),
    Notifier.t(),
    map()
  ) :: Success.t() | Error.t() | Exception.t()
  def create(
    transformer_code_store,
    notifier,
    args
  ) when is_atom(transformer_code_store) and is_atom(notifier) do
      with needle <- Map.get(args, :needle), 
           {:ok, entity} <- Builder.build(Email, needle),
           {:ok, _} <- transformer_code_store.transform(entity),
           {:ok, _} <- notifier.notify(%Core.Shared.Types.Notification{
              to: needle,
              from: @from,
              subject: "Подтвердите адрес электронной почты",
              message: "Ваш код - #{entity.code}"
           }) do
      {:ok, true}
    else
      {:error, error} -> {:error, error}
      {:exception, error} -> {:exception, error}
    end
  end

  def create(_, _, _) do
    {:error, "Невалидные аргументы для создания кода подтверждения"}
  end
end
