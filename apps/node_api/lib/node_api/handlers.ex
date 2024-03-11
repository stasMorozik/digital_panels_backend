defmodule NodeApi.Handlers do
  
  @name_node Application.compile_env(:node_api, :name_node)
  @to Application.compile_env(:node_api, :developer_telegram_login)
  @from Application.compile_env(:core, :email_address)

  def handle_exception(conn, error) do
    ModLogger.Logger.exception(%{
      message: error, 
      node: @name_node
    })

    NotifierAdapters.SenderToDeveloper.notify(%{
      to: @to,
      from: @from,
      subject: "Exception",
      message: error
    })

    conn 
      |> Plug.Conn.send_resp(500, Jason.encode!(%{message: "Что то пошло не так"}))
  end

  def handle_error(conn, message, code) do
    ModLogger.Logger.info(%{
      message: message, 
      node: @name_node
    })

    conn 
      |> 
      Plug.Conn.send_resp(code, Jason.encode!(%{message: message}))
  end
end