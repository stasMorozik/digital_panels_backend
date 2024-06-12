defmodule NodeApi.Utils.Parsers.Boolean do
  def parse(map, name) do
    value = Map.get(map, name)

    cond do
      value == nil -> nil
      value == "true" -> true
      value == "false" -> false
      value == "1" -> true
      value == "0" -> false
      true -> nil
    end
  end
end