defmodule NodeApi.ConfirmationCode.Controller do

  alias Core.ConfirmationCode.UseCases.Creating
  alias PostgresqlAdapters.ConfirmationCode.Inserting

  def create(conn) do
    args = %{needle: Map.get(conn.body_params, "needle")}

    adapter_0 = Inserting
    adapter_1 = NodeApi.NotifierUser

    try do
      case Creating.create(adapter_0, adapter_1, args) do
        {:ok, true} -> 
          NodeApi.Logger.info("Создан код подтверждения")

          json = Jason.encode!(true)

          conn |> Plug.Conn.send_resp(200, json)
          
        {:error, message} -> 
          NodeApi.Handlers.handle_error(conn, message, 400)

        {:exception, message} -> 
          NodeApi.Handlers.handle_exception(conn, message)
      end
    rescue
      e -> NodeApi.Handlers.handle_exception(conn, e)
    end
  end
end