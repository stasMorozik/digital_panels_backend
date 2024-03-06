defmodule PostgresqlAdapters.Task.GettingById do
  alias Core.Task.Ports.Getter
  alias Core.Task.Entity, as: Task
  alias Core.User.Entity, as: User
  
  alias PostgresqlAdapters.Executor

  @behaviour Getter

  @query "
    SELECT 
      tasks.id AS task_id,
      tasks.name AS task_nm,
      tasks.type AS task_tp,
      tasks.day AS task_day,
      tasks.start_hour AS task_start_h,
      tasks.end_hour AS task_end_h,
      tasks.start_minute AS task_start_m,
      tasks.end_minute AS task_end_m,
      tasks.start_hm AS task_start_hm,
      tasks.end_hm  AS task_end_hm,
      tasks.sum  AS task_sum,
      tasks.created AS task_cr,
      tasks.updated AS task_upd,
      groups.id AS gr_id,
      groups.name AS gr_nm,
      groups.created AS gr_cr,
      groups.updated AS gr_upd,
      playlists.id AS pl_id,
      playlists.name AS pl_nm,
      playlists.created AS pl_cr,
      playlists.updated AS pl_upd,
      contents.id AS cnt_id,
      contents.name AS cnt_nm,
      contents.duration AS cnt_dur,
      contents.serial_number AS cnt_num,
      contents.created AS cnt_cr,
      contents.updated AS upd_cr,
      files.id AS fl_id,
      files.path AS fl_pt,
      files.url AS fl_url,
      files.extension AS fl_ext,
      files.type AS fl_tp,
      files.size AS fl_s,
      files.created AS fl_cr
    FROM 
      relations_user_task 
    JOIN tasks ON 
      relations_user_task.task_id = tasks.id
    JOIN groups ON
      tasks.group_id = groups.id
    JOIN playlists ON
      tasks.playlist_id = playlists.id
    LEFT JOIN contents ON
      contents.playlist_id = playlists.id
    LEFT JOIN files ON
      contents.file_id = files.id
    WHERE
      relations_user_task.user_id = $1 
    AND
      tasks.id = $2
    ORDER BY contents.serial_number 
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
              _, _, _, _, _, _, _, _, _, _, _, _, _,
              _, _, _, _,
              _, _, _, _,
              cnt_id, cnt_nm, cnt_dur, cnt_num, cnt_cr, cnt_upd,
              fl_id, fl_pt, fl_url, fl_ext, fl_tp, fl_s, fl_cr
             ]) -> 
                %Core.Content.Entity{
                  id: UUID.binary_to_string!(cnt_id),
                  name: cnt_nm,
                  duration: cnt_dur,
                  file: %Core.File.Entity{
                    id: UUID.binary_to_string!(fl_id), 
                    path: fl_pt, 
                    url: fl_url, 
                    extension: fl_ext, 
                    type: fl_tp, 
                    size: fl_s, 
                    created: fl_cr
                  },
                  serial_number: cnt_num,
                  created: cnt_cr,
                  updated: cnt_upd
                }
             end,
             [row | _] <- result.rows,
             [
              task_id, task_nm, task_tp, task_day,
              task_start_h, task_end_h, task_start_m, task_end_m,
              task_start_hm, task_end_hm, task_sum, task_cr, task_upd,

              gr_id, gr_nm, gr_cr, gr_upd,
              pl_id, pl_nm, pl_cr, pl_upd,
              _, _, _, _, _, _,
              fl_id, _, _, _, _, _, _
             ] <- row do
          {:ok, %Task{
            id: UUID.binary_to_string!(task_id),
            name: task_nm,
            type: task_tp,
            day: task_day,
            start_hour: task_start_h,
            end_hour: task_end_h,
            start_minute: task_start_m,
            end_minute: task_end_m,
            start: task_start_hm,
            end: task_end_hm,
            sum: task_sum,
            created: task_cr,
            updated: task_upd,
            playlist: %Core.Playlist.Entity{
              id: UUID.binary_to_string!(pl_id), 
              name: pl_nm,
              contents: case fl_id == nil do
                true -> nil
                false -> Enum.map(result.rows, fun)
              end,
              created: pl_cr,
              updated: pl_upd
            },
            group: %Core.Group.Entity{
              id: UUID.binary_to_string!(gr_id),
              name: gr_nm,
              created: gr_cr, 
              updated: gr_upd
            },
          }}
        else
          false -> {:error, "Запись о задании не найдена в базе данных"}
          {:exception, message} -> {:exception, message}
        end

      [] -> {:exception, "Database connection error"}
      _ -> {:exception, "Database connection error"}
    end
  end

  def get(_, _) do
    {:error, "Не валидные данные для получения записи о задании из базы данных"}
  end
end
