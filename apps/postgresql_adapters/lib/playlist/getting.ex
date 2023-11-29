defmodule PostgresqlAdapters.Playlist.Getting do
  alias Core.Playlist.Ports.Getter
  alias PostgresqlAdapters.Playlist.Mapper

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error
  alias Core.Shared.Types.Exception

  alias PostgresqlAdapters.Executor

  @behaviour Getter

  @impl Getter
  def get(id) when is_binary(id) do
    case :ets.lookup(:connections, "postgresql") do
      [{"postgresql", "", connection}] ->
        with query <- "SELECT id, name, contents, created updated FROM playlists WHERE id = $1",
             {:ok, result} <- Executor.execute(query, [id]),
             true <- result.num_rows > 0,
             [ row ] <- result.rows do
          Mapper.to_entity(row)
        else
          false -> Error.new("Плэйлист не найден")
          {:exception, message} -> {:exception, message}
        end
      [] -> Exception.new("Database connection error")
      _ -> Exception.new("Database connection error")
    end
  end

  def get(_) do
    Error.new("Не валидные данные для получения пользователя")
  end
end
