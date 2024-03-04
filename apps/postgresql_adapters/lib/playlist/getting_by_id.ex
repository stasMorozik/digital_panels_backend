defmodule PostgresqlAdapters.Playlist.GettingById do
  alias Core.Playlist.Ports.Getter
  alias Core.Playlist.Entity, as: Playlist
  alias Core.User.Entity, as: User
  
  alias PostgresqlAdapters.Executor

  @behaviour Getter

  @query "
    SELECT 
      playlist.id AS pl_id,
      playlist.name AS pl_name,
      playlist.sum AS pl_sum,
      playlist.created AS pl_cr,
      playlist.updated AS pl_upd,
      contents.id AS cnt_id,
      contents.name AS cnt_name,
      contents.duration AS cnt_dur,
      contents.serial_number AS cnt_num,
      contents.created AS cnt_cr,
      contents.updated AS cnt_upd,
      files.id AS fl_id,
      files.path AS fl_path,
      files.url AS fl_url,
      files.extension AS fl_ext,
      files.type AS fl_type,
      files.size AS fl_sz,
      files.created AS fl_cr
    FROM 
      relations_user_playlist 
    JOIN playlist ON 
      relations_user_playlist.playlist_id = playlist.id
    LEFT JOIN contents ON
      contents.playlist_id = playlist.id
    LEFT JOIN files ON
      contents.file_id = files.id
    ORDER BY 
      contents.serial_number
    WHERE
      relations_user_playlist.user_id = $1 
    AND
      playlist.id = $2
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
             fun <- fn ([
                _,
                _,
                _,
                _,
                _,
                cnt_id,
                cnt_name,
                cnt_dur,
                cnt_num,
                cnt_cr,
                cnt_upd,
                fl_id,
                fl_path,
                fl_url,
                fl_ext,
                fl_type,
                fl_sz,
                fl_cr
             ]) -> 
                %Core.Content.Entity{
                  id: UUID.binary_to_string!(cnt_id),
                  name: cnt_name,
                  duration: cnt_dur,
                  file: %Core.File.Entity{
                    id: UUID.binary_to_string!(fl_id), 
                    path: fl_path, 
                    url: fl_url, 
                    extension: fl_ext, 
                    type: fl_type, 
                    size: fl_sz, 
                    created: fl_cr
                  },
                  serial_number: cnt_num,
                  created: cnt_cr,
                  updated: cnt_upd
                }
             end,
             [row] <- result.rows,
             [  
                pl_id, 
                pl_name, 
                pl_sum, 
                pl_cr, 
                pl_upd, 
                _, 
                _, 
                _, 
                _, 
                _, 
                _, 
                _, 
                fl_path, 
                _, 
                _,
                _, 
                _,
                _
             ] <- row do
          {:ok, %Playlist{
            id: UUID.binary_to_string!(pl_id),
            name: pl_name,
            sum: pl_sum,
            contents: case fl_path == nil do
              true -> nil
              false -> Enum.map(result.rows, fun)
            end,
            created: pl_cr,
            updated: pl_upd
          }}
        else
          false -> {:error, "Запись о плэйлисте не найдена в базе данных"}
          {:exception, message} -> {:exception, message}
        end

      [] -> {:exception, "Database connection error"}
      _ -> {:exception, "Database connection error"}
    end
  end

  def get(_, _) do
    {:error, "Не валидные данные для получения записи о плэйлисте из базы данных"}
  end
end
