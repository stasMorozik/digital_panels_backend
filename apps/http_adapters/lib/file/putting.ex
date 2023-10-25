defmodule HttpAdapters.File.Putting do
  alias Core.File.Ports.Transformer
  
  alias Core.File.Entity, as: FileEntity
  alias Core.User.Entity, as: UserEntity

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

  @behaviour Transformer

  @impl Transformer
  def transform(%FileEntity{
    id: id,
    size: _,
    url: url,
    path: path,
    created: _,
    updated: _
  }, _) do
    user = Application.fetch_env!(:http_adapters, :user)
    password = Application.fetch_env!(:http_adapters, :password)

    case HTTPoison.put(
      url,
      {:file, path},
      [{"Authorization", "Basic #{user}:#{password}"}]
    ) do
      {:ok, _} -> Success.new(true),
      {:error, _} -> Error.new("Не удалось записать файл на сервер")
    end
  end

  def transform(_, _) do
    Error.new("Не возможно записать файл на сервер")
  end
end
