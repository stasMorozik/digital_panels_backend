defmodule Core.Device.Entity do
  @moduledoc """
    Сущность - устройство
  """

  alias Core.Device.Entity

  @type t :: %Entity{
    id: binary(),
    ip: binary(),
    latitude: float(),
    longitude: float(),
    desc: binary(),
    group: Core.Group.Entity.t(),
    is_active: boolean(),
    created: binary(),
    updated: binary()
  }

  defstruct id: nil, 
            ip: nil, 
            latitude: nil, 
            longitude: nil, 
            desc: nil,
            group: nil,
            is_active: nil,
            created: nil, 
            updated: nil

  defimpl Jason.Encoder, for: Core.Device.Entity do
    @impl Jason.Encoder

    def encode(value, opts) do
      fun = fn {key, value}, acc ->
        case value do
          nil -> acc
          value -> Map.put(acc, key, value)
        end
      end

      group = case Map.get(value, :group) do
        nil -> nil
        group -> List.foldr(Map.to_list(Map.from_struct(group)) , %{}, fun)
      end

      device = Map.from_struct(value)
      device = Map.delete(device, :group)

      device = Map.put(device, :group, group)

      device = Map.to_list(device)
      
      device = List.foldr(device, %{}, fun)

      Jason.Encode.map(device, opts)
    end
  end
end
