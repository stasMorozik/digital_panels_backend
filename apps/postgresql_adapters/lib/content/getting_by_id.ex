defmodule PostgresqlAdapters.Content.GettingById do
  alias Core.Content.Ports.Getter
  alias Core.Content.Entity, as: Content
  alias Core.User.Entity, as: User
  
  alias PostgresqlAdapters.Executor

  @behaviour Getter

  @query "
    SELECT 
      contents.id AS cnt_id,
      contents.name AS cnt_name,
      contents.duration AS cnt_dur,
      contents.serial_number AS cnt_num,
      contents.created AS cnt_cr,
      contents.updated AS cnt_upd,
      files.id AS fl_id,
      files.path AS fl_p,
      files.url AS fl_url,
      files.extension AS fl_ext,
      files.type AS fl_t,
      files.size AS fl_s,
      files.created AS fl_cr,
      playlists.id AS pl_id,
      playlists.name AS pl_name,
      playlists.created AS pl_cr,
      playlists.updated AS pl_upd,
    FROM 
      relations_user_content 
    JOIN contents ON 
      relations_user_content.content_id = contents.id
    JOIN files ON
      contents.file_id = files.id
    JOIN playlists ON
      contents.playlist_id = playlists.id
    WHERE
      relations_user_content.user_id = $1 
    AND
      contents.id = $2
  "

  @impl Getter
  def get(id, %User{} = user) when is_binary(id) do
    case :ets.lookup(:connections, "postgresql") do
      [{"postgresql", "", connection}] ->
        with {:ok, result} <- Executor.execute(connection, @query, [
                UUID.string_to_binary!(user.id), 
                UUID.string_to_binary!(id)
             ]),
             true <- result.num_rows > 0,
             [row] <- result.rows,
             [
                cnt_id,
                cnt_name,
                cnt_dur,
                cnt_num,
                cnt_cr,
                cnt_upd,
                fl_id,
                fl_p,
                fl_url,
                fl_ext,
                fl_t,
                fl_s,
                fl_cr,
                pl_id,
                pl_name,
                pl_cr,
                pl_upd,
             ] <- row do
          {:ok, %Content{
            id: UUID.binary_to_string!(cnt_id),
            name: cnt_name,
            duration: cnt_dur,
            file: %Core.File.Entity{
              id: UUID.binary_to_string!(fl_id), 
              path: fl_p, 
              url: fl_url, 
              extension: fl_ext, 
              type: fl_t, 
              size: fl_s, 
              created: fl_cr
            },
            playlist: %Core.Playlist.Entity{
              id: UUID.binary_to_string!(pl_id),
              name: pl_name,
              created: pl_cr,
              updated: pl_upd
            },
            serial_number: cnt_num,
            created: cnt_cr,
            updated: cnt_upd
          }}
        else
          false -> {:error, "Запись о контенте не найдена в базе данных"}
          {:exception, message} -> {:exception, message}
        end

      [] -> {:exception, "Database connection error"}
      _ -> {:exception, "Database connection error"}
    end
  end

  def get(_, _) do
    {:error, "Не валидные данные для получения записи о контенте из базы данных"}
  end
end
