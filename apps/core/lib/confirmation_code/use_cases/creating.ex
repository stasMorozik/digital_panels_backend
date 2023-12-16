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
      with email <- Map.get(args, :email), 
           {:ok, entity} <- Builder.build(Email, email),
           {:ok, _} <- transformer_code_store.transform(entity),
           {:ok, _} <- notifier.notify(%{
              to: email,
              from: Application.fetch_env!(:core, :email_address),
              subject: "Подтердите адрес электронной почты",
              message: "Ваш код - #{entity.code}"
           }) do

      {:ok, true}

    else
      {:error, error} -> {:error, error}
      {:exception, error} -> {:exception, error}
    end
  end

  def create(_, _, _) do
    {:error, "Не валидные аргументы для создания кода подтверждения"}
  end
end
