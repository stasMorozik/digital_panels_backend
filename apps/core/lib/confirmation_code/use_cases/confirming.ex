defmodule Core.ConfirmationCode.UseCases.Confirming do
  @moduledoc """
    Юзекейз подтверждения кода
  """

  alias Core.ConfirmationCode.Ports.Transformer
  alias Core.ConfirmationCode.Ports.Getter
  alias Core.ConfirmationCode.Methods.Confirmation

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error
  alias Core.Shared.Types.Exception

  @spec confirm(
    Transformer.t(),
    Getter.t(),
    map()
  ) :: Success.t() | Error.t() | Exception.t()
  def confirm(
    transformer,
    getter,
    args
  ) when is_atom(transformer) and is_atom(getter) and is_map(args) do
    with true <- Kernel.function_exported?(transformer, :transform, 1),
         true <- Kernel.function_exported?(getter, :get, 1),
         {:ok, code_entity} <- getter.get(Map.get(args, :needle)),
         {:ok, code_entity} <- Confirmation.confirm(code_entity, Map.get(args, :code)),
         {:ok, _} <- transformer.transform(code_entity) do
      Success.new(true)
    else
      {:error, error} -> {:error, error}
      false -> Error.new("Не валидные данные для подтверждения кода")
      {:exception, error} -> {:exception, error}
    end
  end

  def confirm(_, _, _) do
    Error.new("Не валидные данные для подтверждения кода")
  end
end
