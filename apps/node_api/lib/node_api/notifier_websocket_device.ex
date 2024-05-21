defmodule NodeApi.NotifierWebsocketDevice do  
  @query "
    SELECT 
      tasks.id AS task_id,
      groups.id AS gr_id,
      playlists.id AS pl_id
    FROM 
      playlists 
    JOIN tasks ON 
      tasks.playlist_id = playlists.id
    JOIN groups ON
      tasks.group_id = groups.id
    WHERE
      playlists.id = $1
  "
  
  
  def notify(%{group_id: group_id}) do
    {:ok, chann} = AMQP.Application.get_channel(:chann)

    AMQP.Basic.publish(chann, "websocket_device", "content_change", Jason.encode!(%{
      group_id: group_id
    }))
    
    {:ok, true}
  end

  def notify(%{playlist_id: playlist_id}) do
    case :ets.lookup(:connections, "postgresql") do
      [{"postgresql", "", connection}] ->
        with {:ok, query} <- Postgrex.prepare(connection, "", @query),
             {:ok, _, result} <- Postgrex.execute(connection, query, [playlist_id]),
             {:ok, chann} = AMQP.Application.get_channel(:chann),
             fun <- fn ([_, gr_id, _]) do
                AMQP.Basic.publish(chann, "websocket_device", "content_change", Jason.encode!(%{
                  group_id: gr_id,
                }))
             end
          
          Enum.each(result, fun)

          {:ok, true}
        else
          {:error, e} -> {:exception, e.postgres.message}
        end

      [] -> 
        {:exception, "Database connection error"}
      _ -> 
        {:exception, "Database connection error"}
    end
  end
end