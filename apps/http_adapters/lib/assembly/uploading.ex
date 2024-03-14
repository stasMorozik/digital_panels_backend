defmodule HttpAdapters.Assembly.Uploading do

  alias Core.Assembly.Ports.Transformer
  alias Core.Assembly.Entity, as: Assembly
  alias Core.User.Entity, as: User

  @behaviour Transformer

  @user_web_dav Application.compile_env(:http_adapters, :user_web_dav)
  @password_web_dav Application.compile_env(:http_adapters, :password_web_dav)

  @paths %{
    "Windows": Application.compile_env(:http_adapters, :path_windows_bundle),
    "Linux": Application.compile_env(:http_adapters, :path_linux_bundle),
    "Android": Application.compile_env(:http_adapters, :path_android_bundle)
  }

  @impl Transformer
  def transform(%Assembly{} = assembly, %User{} = _user) do
    with path_bandle <- Map.get(@paths, String.to_atom(assembly.type)),
         files_0 <- create_files_list("#{path_bandle}data", path_bandle),
         files_1 <- create_files_list("#{path_bandle}lib", path_bandle),
         name_file <- String.to_charlist(Path.basename("#{path_bandle}panel")), 
         files_2 <- [{name_file, File.read!("#{path_bandle}panel")}],
         name_file <- String.to_charlist(Path.basename("/tmp/#{assembly.id}/local.db")), 
         files_3 <- [{name_file, File.read!("/tmp/#{assembly.id}/local.db")}],
         files <- files_0 ++ files_1 ++ files_2 ++ files_3,
         {:ok, _} <- :zip.create("/tmp/#{assembly.id}.zip", files),
         header <- "Basic " <> Base.encode64("#{@user_web_dav}:#{@password_web_dav}"),
         headers <- [{"Authorization", header}],
         body <- {:file, "/tmp/#{assembly.id}.zip"} do
      
      case HTTPoison.put(assembly.url, body, headers) do
        {:ok, %HTTPoison.Response{
          status_code: code
        }} when code >= 200 and code <= 299 ->
          {:ok, true}
        {:ok, %HTTPoison.Response{
          body: _body,
          status_code: code
        }} when code >= 400 and code <= 599 ->
          {:exception, "Не удалось сохранить файл на сервер, статус овтета - #{code}"}
        {:error, e} -> {:exception, e.reason}
      end

    else
      false -> {:exception, "Не удалось найти папку со сборкой"}
      {:error, _} -> {:exception, "Не удалось собрать архив со сборкой"}
    end
  end

  def transform(_, _) do
    {:error, "Не валидные данные для сохранения файла на сервере"}
  end

  defp create_files_list(path, path_bandle) do
    create_files_list(File.ls!(path), path, path_bandle)
  end
  
  defp create_files_list(paths, path, path_bandle) do
    create_files_list(paths, path, path, path_bandle)
  end

  defp create_files_list(paths, path, base_path, path_bandle) do
    Enum.reduce(paths, [],
      fn(filename, acc) ->
        filename_path = Path.join(path, filename)
        case File.dir?(filename_path) do
          true -> acc ++ create_files_list(File.ls!(filename_path), filename_path, base_path, path_bandle)
          false -> 
            [{String.to_char_list(
              case String.length(base_path) > 0 do
                true -> String.replace_leading(filename_path, path_bandle, "")
                false -> filename_path  
              end
            ), File.read!(filename_path)} | acc]
        end
      end
    )
  end
end