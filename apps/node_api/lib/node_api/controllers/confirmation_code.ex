defmodule NodeApi.Controllers.ConfirmationCode do

  alias Core.ConfirmationCode.UseCases.Creating
  alias PostgresqlAdapters.ConfirmationCode.Inserting

  alias NodeApi.Handlers.Success
  alias NodeApi.Handlers.Error
  alias NodeApi.Handlers.Exception

  alias NodeApi.Logger, as: AppLogger

  def create(conn) do
    args = %{needle: Map.get(conn.body_params, "needle")}

    adapter_0 = Inserting
    adapter_1 = NodeApi.Notifiers.User

    try do
      case Creating.create(adapter_0, adapter_1, args) do
        {:ok, true} -> 
          AppLogger.info("Создан код подтверждения")
          
          Success.handle(conn, true)
        {:error, message} -> 
          Error.handle(conn, message)
        {:exception, message} -> 
          Exception.handle(conn, message)
      end
    rescue
      e -> 
        Exception.handle(conn, Map.get(e, :message))
    end
  end
end