defmodule NodeApi.Logger do

  @name_node_api Application.compile_env(:node_api, :name_node_api)

  @where {
    Application.compile_env(:node_api, :name_process_logger), 
    Application.compile_env(:node_api, :name_node_logger)
  }
  
  def exception(message) do
    Process.send(@where, {:exception, gen_message(message)}, [:noconnect])
  end

  def info(message) do
    Process.send(@where, {:info, gen_message(message)}, [:noconnect])
  end

  def debug(message) do
    Process.send(@where, {:debug, gen_message(message)}, [:noconnect])
  end

  defp gen_message(m) do
     %{message: m, date: DateTime.utc_now(), app: @name_node_api}
  end
end