defmodule HttpAdapters.File.Putting do
  use HTTPoison.Base

  alias Core.File.Ports.Transformer
  
  alias Core.File.Entity, as: FileEntity
  alias Core.User.Entity, as: UserEntity

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error
  alias Core.Shared.Types.Exception

  @behaviour Transformer

  @impl Transformer
  def transform(%FileEntity{
    id: _,
    size: _,
    url: url,
    path: path,
    created: _,
    updated: _
  }, _) do
    user = Application.fetch_env!(:http_adapters, :user)
    password = Application.fetch_env!(:http_adapters, :password)
    header_content = "Basic " <> Base.encode64("#{user}:#{password}")

    case HTTPoison.put(
      url,
      {:file, path},
      [{"Authorization", header_content}]
    ) do
      {:ok, %HTTPoison.Response{
        status_code: code
      }} when code >= 200 and code <= 299 ->
        Success.new(true)
      {:ok, %HTTPoison.Response{
        status_code: code
      }} when code >= 400 and code <= 599 ->
        Exception.new("Не удалось записать файл на сервер, статус овтета - #{code}")
      {:error, e} -> 
        Exception.new(e.reason)
    end
  end

  def transform(_, _) do
    Error.new("Не возможно записать файл на сервер")
  end
end
