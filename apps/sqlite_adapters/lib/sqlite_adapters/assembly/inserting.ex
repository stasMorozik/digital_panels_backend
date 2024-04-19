defmodule SqliteAdapters.Assembly.Inserting do
  
  alias Core.Assembly.Ports.Transformer
  alias Core.Assembly.Entity, as: Assembly
  alias Core.User.Entity, as: User

  @behaviour Transformer

  @paths %{
    "Windows": Application.compile_env(:sqlite_adapters, :path_windows_bundle),
    "Linux": Application.compile_env(:sqlite_adapters, :path_linux_bundle),
    "Android": Application.compile_env(:sqlite_adapters, :path_android_bundle)
  }

  @create_table_0 "create table tokens (a_t text, r_t text)"

  @create_table_1 "create table groups (id text primary key, name text)"

  @query_0 "insert into tokens (a_t, r_t) values (?1, ?2)"

  @query_1 "insert into groups (id, name) values (?1, ?2)"

  @impl Transformer
  def transform(%Assembly{} = assmbl, %User{} = _user) do
    with path_bandle <- Map.get(@paths, String.to_atom(assmbl.type)),
         true <- File.exists?(path_bandle),
         true <- File.exists?("#{path_bandle}local.db"),
         :ok <- File.mkdir("/tmp/#{assmbl.id}/"),
         :ok <- File.cp("#{path_bandle}local.db", "/tmp/#{assmbl.id}/local.db"),
         {:ok, conn} = Exqlite.Sqlite3.open("/tmp/#{assmbl.id}/local.db"),
         :ok <- Exqlite.Sqlite3.execute(conn, @create_table_0),
         :ok <- Exqlite.Sqlite3.execute(conn, @create_table_1),
         {:ok, statement} = Exqlite.Sqlite3.prepare(conn, @query_0),
         :ok <- Exqlite.Sqlite3.bind(conn, statement, [assmbl.access_token, assmbl.refresh_token]),
         :done <- Exqlite.Sqlite3.step(conn, statement),
         {:ok, statement} = Exqlite.Sqlite3.prepare(conn, @query_1),
         :ok <- Exqlite.Sqlite3.bind(conn, statement, [assmbl.group.id, assmbl.group.name]),
         :done <- Exqlite.Sqlite3.step(conn, statement) do
      {:ok, true}
    else
      false -> {:exception, "Не удалось найти файл базы данных в сборке"}
      {:error, _} -> {:exception, "Не удалось внести изменения в файл базы данных сборки"}
    end
  end

  def transform(_, _) do
    {:error, "Не валидные данные для занесения записи о сборке в базу данных"}
  end
end