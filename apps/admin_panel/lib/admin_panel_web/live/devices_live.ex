defmodule AdminPanelWeb.DevicesLive do
  use AdminPanelWeb, :live_view

  def mount(_params, session, socket) do
    socket = assign(socket, :state, %{
      success_sending_confirmation_code: nil,
      success_confirm_confirmation_code: nil,
      error: nil,
      form: to_form( %{email: "", code: ""} )
    })

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""

    """
  end
end
