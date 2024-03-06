defmodule ConfirmationCode.FakeAdapters.Inserting do
  alias Core.ConfirmationCode.Ports.Transformer

  @behaviour Transformer

  alias Core.ConfirmationCode.Entity

  @impl Transformer
  def transform(%Entity{
    needle: needle,
    created: created,
    code: code,
    confirmed: confirmed
  }) do
    case :mnesia.transaction(
      fn -> :mnesia.write({:codes, needle, created, code, confirmed}) end
    ) do
      {:atomic, :ok} -> {:ok, true}
      {:aborted, _} -> {:error, "Код уже существует"}
    end
  end
end