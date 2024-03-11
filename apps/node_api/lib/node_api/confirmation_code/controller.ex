defmodule NodeApi.ConfirmationCode.Controller do

  alias Core.ConfirmationCode.UseCases.Creating
  alias PostgresqlAdapters.ConfirmationCode.Inserting
  alias NodeApi.NotifierUser

  @name_node Application.compile_env(:node_api, :name_node)

  def create(conn) do
    args = %{needle: Map.get(conn.body_params, "needle")}

    try do
      case Creating.create(Inserting, NotifierUser, args) do
        {:ok, true} -> 
          ModLogger.Logger.info(%{
            message: "Создан код подтверждения", 
            node: @name_node
          })
          
          conn 
            |> Plug.Conn.send_resp(200, Jason.encode!(true))

        {:error, message} -> NodeApi.Handlers.handle_error(conn, message, 400)

        {:exception, message} -> NodeApi.Handlers.handle_exception(conn, message)
      end
    rescue
      e -> NodeApi.Handlers.handle_exception(conn, e)
    end
  end
end