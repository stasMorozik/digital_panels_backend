defmodule HttpAdapters.File.Uploading do

  alias Core.File.Ports.Transformer
  alias Core.File.Entity, as: File
  alias Core.User.Entity, as: User

  @behaviour Transformer

  @user_web_dav Application.compile_env(:http_adapters, :user_web_dav)
  @password_web_dav Application.compile_env(:http_adapters, :password_web_dav)

  @impl Transformer
  def transform(%File{} = file, %User{} = user) do
    header_content = "Basic " <> Base.encode64("#{@user_web_dav}:#{@password_web_dav}")
    
    case HTTPoison.put(
      file.url,
      {:file, file.path},
      [{"Authorization", header_content}]
    ) do
      {:ok, %HTTPoison.Response{
        status_code: code
      }} when code >= 200 and code <= 299 ->
        {:ok, true}
      {:ok, %HTTPoison.Response{
        status_code: code
      }} when code >= 400 and code <= 599 ->
        {:exception, "Не удалось сохранить файл на сервер, статус овтета - #{code}"}
      {:error, e} -> 
        {:exception, e.reason}
    end
  end

  def transform(_, _) do
    {:error, "Не валидные данные для сохранения файла на сервере"}
  end
end