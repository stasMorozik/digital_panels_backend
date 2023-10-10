defmodule FakeAdapters.ConfirmationCode.Getter do
  alias Core.ConfirmationCode.Ports.Getter
  alias Core.ConfirmationCode.Entity

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

  @behaviour Getter

  @impl Getter
  def get(email) when is_binary(email) do
    case :mnesia.transaction(fn -> :mnesia.read(:codes, email) end) do
      {:atomic, list_codes} ->
        if length(list_codes) > 0 do

          [confirmation_code | _] = list_codes

          {:codes, needle, created, code, confirmed} = confirmation_code

          Success.new(%Entity{
            needle: needle,
            created: created,
            code: code,
            confirmed: confirmed
          })

        else
          Error.new("Код не найден")
        end
      {:aborted, _} -> Error.new("Код не найден")
    end
  end

  def get(_) do
    Error.new("Не валидный адрес электронной почты")
  end
end
