defmodule NodeApi.Utils.Parsers.Float do
  def parse(map, name) do
    value = Map.get(map, name)

    with false <- value == nil,
         false <- is_float(value),
         {v, _} <- Float.parse(value) do
      v
    else
      true -> value
      :error -> nil
    end
  end
end