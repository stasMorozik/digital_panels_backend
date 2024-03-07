defmodule NodeApi.Handlers do

  alias NodeApi.Logger
  alias NodeApi.NotifierDev

  @from Application.compile_env(:core, :email_address)
  @developer_telegram_login Application.compile_env(:node_api, :developer_telegram_login)

  def handle_exception(conn, error) do
    Logger.exception(error)

    NotifierDev.notify(%{
      to: @developer_telegram_login,
      from: @from,
      subject: "Exception",
      message: error
    })

    conn 
      |> Plug.Conn.send_resp(500, Jason.encode!(%{message: "Что то пошло не так"}))
  end

  def handle_error(conn, message, code) do
    Logger.info(message)

    conn 
      |> Plug.Conn.send_resp(code, Jason.encode!(%{message: message}))
  end
end