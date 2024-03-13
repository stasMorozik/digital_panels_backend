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

  @create_table_0 "create table tokens (a_t text, r_t text)"

  @create_table_1 "create table groups (id text primary key, name text)"

  @query_0 "insert into tokens (a_t, r_t) values (?1, ?2)"

  @query_1 "insert into groups (id, name) values (?1, ?2)"

  @impl Transformer
  def transform(%Assembly{} = assembly, %User{} = _user) do
    with path_bandle <- Map.get(@paths, String.to_atom(assembly.type)),
         true <- File.exists?(path_bandle),
         true <- File.exists?("#{path_bandle}data"),
         true <- File.exists?("#{path_bandle}lib"),
         true <- File.exists?("#{path_bandle}panel"),
         true <- File.exists?("#{path_bandle}local.db"),
         :ok <- File.mkdir("/tmp/#{assembly.id}/"),
         :ok <- File.cp("#{path_bandle}local.db", "/tmp/#{assembly.id}/local.db"),
         {:ok, conn} = Exqlite.Sqlite3.open("/tmp/#{assembly.id}/local.db"),
         :ok <- Exqlite.Sqlite3.execute(conn, @create_table_0),
         :ok <- Exqlite.Sqlite3.execute(conn, @create_table_1),
         {:ok, statement} = Exqlite.Sqlite3.prepare(conn, @query_0),
         :ok <- Exqlite.Sqlite3.bind(
           conn, statement, [assembly.access_token, assembly.refresh_token]
         ),
         :done <- Exqlite.Sqlite3.step(conn, statement),
         {:ok, statement} = Exqlite.Sqlite3.prepare(conn, @query_1),
         :ok <- Exqlite.Sqlite3.bind(
           conn, statement, [assembly.group.id, assembly.group.name]
         ),
         :done <- Exqlite.Sqlite3.step(conn, statement),
         files <- [
            "#{path_bandle}data",
            "#{path_bandle}lib",
            "#{path_bandle}panel",
            "/tmp/#{assembly.id}/local.db"
         ],
         m <- IO.inspect(files),
         m <- IO.inspect(
            File.ls!("#{path_bandle}data")
         ),
         files <- files |> Enum.map(fn (path) ->
            String.to_charlist(path)
         end),
         m <- IO.inspect(files),
         {:ok, file} <- :zip.create("/tmp/#{assembly.id}.zip", files) do
      
      header_content = "Basic " <> Base.encode64("#{@user_web_dav}:#{@password_web_dav}")

      case HTTPoison.put(
        assembly.url,
        {:file, "/tmp/#{assembly.id}.zip"},
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
          IO.inspect(e)
          {:exception, e.reason}
      end

    else
      false -> {:exception, "Не удалось найти папку со сборкой"}
      {:error, _} -> {:exception, "Не удалось скопировать файл базы данных из сборки"}
    end
  end

  def transform(_, _) do
    {:error, "Не валидные данные для сохранения файла на сервере"}
  end
end