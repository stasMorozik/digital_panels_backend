defimpl Jason.Encoder, for: Core.Content.Entity do
  def encode(content_strust, opts) do
    content_map = Map.take(content_strust, [:id, :display_duration, :created, :updated])

    file_struct = Map.get(content_strust, :file)

    file_map = Map.take(file_struct, [:id, :size, :url, :path, :created, :updated])

    Map.put(content_map, :file, file_map)
    
    Jason.Encode.map(content_map, opts)
  end
end