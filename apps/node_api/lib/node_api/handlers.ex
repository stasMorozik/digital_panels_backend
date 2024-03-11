defmodule NodeApi.Handlers do

  alias NodeApi.NotifierDev

  @name_node Application.compile_env(:node_api, :name_node)

  def handle_exception(conn, error) do
    ModLogger.Logger.exception(%{
      message: error, 
      node: @name_node
    })

    NotifierDev.notify(%{
      to: Application.compile_env(:node_api, :developer_telegram_login),
      from: Application.compile_env(:core, :email_address),
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