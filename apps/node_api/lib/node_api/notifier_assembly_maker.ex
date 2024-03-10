defmodule NodeApi.NotifierAssemblyMaker do
  require Logger
  alias Core.Shared.Ports.Notifier

  @where {
    Application.compile_env(:node_api, :name_process_assembly_maker), 
    Application.compile_env(:node_api, :name_node_assembly_maker)
  }

  @behaviour Notifier

  @impl Notifier
  def notify(%{
    to: to,
    from: from,
    subject: subject,
    message: message
  }) do
    Process.send(@where, {:make, %{
      to: to,
      from: from,
      subject: subject,
      message: message
    }}, [:noconnect])

    {:ok, true}
  end

  def notify(_) do
    {:error, "Не валидные данные для отправки задания на сборку"}
  end
end