defmodule PostgresqlAdapters.File.GettingById do
  alias Core.File.Ports.Getter
  alias Core.File.Entity, as: File
  alias Core.User.Entity, as: User
  
  alias PostgresqlAdapters.Executor

  @behaviour Getter

  @query "
    SELECT 
      files.id, 
      files.path, 
      files.url, 
      files.extension, 
      files.type, 
      files.size, 
      files.created
    FROM 
      relations_user_file 
    JOIN files ON 
      relations_user_file.file_id = files.id
    WHERE
      relations_user_file.user_id = $1 
    AND
      files.id = $2
  "

  @impl Getter
  def get(id, %User{} = user) when is_binary(id) do
    case :ets.lookup(:connections, "postgresql") do
      [{"postgresql", "", connection}] ->

        with {:ok, result} <- Executor.execute(connection, @query, [
                UUID.string_to_binary!(user.id), 
                id
             ]),
             true <- result.num_rows > 0,
             [ row ] <- result.rows,
             [ id, path, url, extension, type, size, created ] <- row do
          {:ok, %File{
            id: UUID.binary_to_string!(id),
            path: path,
            url: url,
            extension: extension,
            type: type,
            size: size,
            created: created
          }}
        else
          false -> {:error, "Запись о файле не найдена в базе данных"}
          {:exception, message} -> {:exception, message}
        end

      [] -> {:exception, "Database connection error"}
      _ -> {:exception, "Database connection error"}
    end
  end

  def get(_, _) do
    {:error, "Не валидные данные для получения записи о файле из базы данных"}
  end
end
