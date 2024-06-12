defmodule NodeApi.Controllers.ConfirmationCode do

  alias Core.ConfirmationCode.UseCases.Creating
  alias PostgresqlAdapters.ConfirmationCode.Inserting

  def create(conn) do
    args = %{needle: Map.get(conn.body_params, "needle")}

    adapter_0 = Inserting
    adapter_1 = NodeApi.NotifierUser

    try do
      case Creating.create(adapter_0, adapter_1, args) do
        {:ok, true} -> 
          message = "Создан код подтверждения"
          payload = true
          
          NodeApi.Handlers.Success.handle(conn, payload, message)
        {:error, message} -> 
          NodeApi.Handlers.Error.handle(conn, message)
        {:exception, message} -> 
          NodeApi.Handlers.Exception.handle(conn, message)
      end
    rescue
      e -> NodeApi.Handlers.Exception.handle(conn, Map.get(e.message))
    end
  end
end