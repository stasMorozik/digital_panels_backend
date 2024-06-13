defmodule Core.Group.Entity do
    @moduledoc """
    Сущность - группа
  """

  alias Core.Group.Entity

  @type t :: %Entity{
    id: binary(),
    name: binary(),
    sum: integer(),
    devices: list(Core.Device.Entity.t()),
    created: binary(),
    updated: binary()
  }

  defstruct id: nil, 
            name: nil,
            sum: nil,
            devices: nil, 
            created: nil, 
            updated: nil

  defimpl Jason.Encoder, for: Core.Group.Entity do
    @impl Jason.Encoder

    def encode(value, opts) do
      fun = fn {key, value}, acc ->
        case value do
          nil -> acc
          value -> Map.put(acc, key, value)
        end
      end

      devices = case Map.get(value, :devices) do
        nil -> 
          nil
        devices -> 
          Enum.map(devices, fn d -> 
            device = Map.from_struct(d)
            device = Map.to_list(device)
            List.foldr(device, %{}, fun)
          end)
      end

      group = Map.from_struct(value)
      group = Map.delete(group, :devices)

      group = Map.put(group, :devices, devices)

      group = Map.to_list(group)
      
      group = List.foldr(group, %{}, fun)

      Jason.Encode.map(group, opts)
    end
  end
end