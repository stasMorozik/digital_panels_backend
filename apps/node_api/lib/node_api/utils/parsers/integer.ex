defmodule NodeApi.Utils.Parsers.Integer do
  def parse(map, name) do
    value = Map.get(map, name)

    with false <- value == nil,
         false <- is_integer(value),
         {v, _} <- Integer.parse(value) do
      v
    else
      true -> value
      :error -> nil
    end
  end
end