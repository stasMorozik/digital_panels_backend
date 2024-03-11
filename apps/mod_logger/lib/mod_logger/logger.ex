defmodule ModLogger.Logger do

  @where {
    Application.compile_env(:mod_logger, :name_process), 
    Application.compile_env(:mod_logger, :name_node)
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
    %{message: m, date: DateTime.utc_now()}
  end
end