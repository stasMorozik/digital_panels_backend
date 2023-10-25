defmodule AdminPanelWeb.Components.Presentation.Alerts.Success do
  use Phoenix.Component

  alias Phoenix.LiveView.JS
  import AdminPanelWeb.Gettext

  attr :message, :string, required: true
  attr :rest, :global

  def c(assigns) do
    ~H"""
      <div
        class="border divide-rose-100 p-4 mb-4 text-sm text-green-800 rounded-lg bg-green-50 dark:bg-gray-800 dark:text-green-300"
        role="alert"
        {@rest}
      >
        <%= @message %>
      </div>
    """
  end
end
