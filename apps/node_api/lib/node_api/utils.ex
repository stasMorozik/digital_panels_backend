defmodule NodeApi.Utils do
  
  def integer_parse(map, name) do
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

  def float_parse(map, name) do
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

  def boolen_parse(map, name) do
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