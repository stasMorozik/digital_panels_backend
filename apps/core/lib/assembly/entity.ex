defmodule Core.Assembly.Entity do
  @moduledoc """
    Тип - тайминг
  """

  alias Core.Assembly.Entity

  @type t :: %Entity{
    id: binary(),
    group: Core.Group.Entity.t(),
    url: binary(),
    type: binary(),
    status: boolean(),
    access_token: binary(),
    refresh_token: binary(),
    created: binary(),
    updated: binary()
  }

  defstruct id: nil,
            group: nil,
            url: nil,
            type: nil,
            status: nil,
            access_token: nil,
            refresh_token: nil,
            created: nil,
            updated: nil


  defimpl Jason.Encoder, for: Core.Assembly.Entity do
    @impl Jason.Encoder

    def encode(value, opts) do
      fun = fn {key, value}, acc ->
        case value do
          nil -> acc
          value -> Map.put(acc, key, value)
        end
      end

      group = Map.from_struct(value.group)

      group = Map.to_list(group)

      group = List.foldr(group, %{}, fun)

      assembly = Map.delete(value, :group)

      assembly = Map.from_struct(assembly)

      assembly = Map.to_list(assembly)
      
      assembly = List.foldr(assembly, %{}, fun)

      assembly = Map.put(assembly, :group, group)

      Jason.Encode.map(assembly, opts)
    end
  end
end