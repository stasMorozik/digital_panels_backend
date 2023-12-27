defmodule ConfirmationCode.FakeAdapters.Getting do
  alias Core.ConfirmationCode.Ports.Getter

  @behaviour Getter

  alias Core.ConfirmationCode.Entity

  @impl Getter
  def get(needle) do
    case :mnesia.transaction(fn -> :mnesia.read({:codes, needle}) end) do
      {:atomic, list_codes} -> 
        case length(list_codes) > 0 do
          false -> {:error, "Код не найден"}
          true -> 
            [code | _] = list_codes

            {:codes, needle, created, code, confirmed} = code

            {:ok, %Entity{
              needle: needle,
              created: created,
              code: code,
              confirmed: confirmed
            }}
        end
      {:aborted, a} -> {:error, "Код не найден"}
    end
  end
end