defmodule Api.Logger do

  @node_logger Application.compile_env(:api, :node_logger)
  @name_logger Application.compile_env(:api, :name_logger)
  
  def exception(message) do
    Process.send({@name_logger, @node_logger}, {:exception, message}, [:noconnect])
  end

  def info(message) do
    Process.send({@name_logger, @node_logger}, {:info, message}, [:noconnect])
  end

  def debug(message) do
    Process.send({@name_logger, @node_logger}, {:debug, message}, [:noconnect])
  end
end