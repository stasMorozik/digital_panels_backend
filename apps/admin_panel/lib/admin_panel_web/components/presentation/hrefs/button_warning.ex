defmodule AdminPanelWeb.Components.Presentation.Hrefs.ButtonWarning do
  use Phoenix.Component

  alias Phoenix.LiveView.JS
  import AdminPanelWeb.Gettext

  attr :text, :string, required: true
  attr :rest, :global

  def c(assigns) do
    ~H"""
      <a
        class="border border-gray-300 text-center text-white bg-red-500 rounded-md p-1 focus:ring-4 focus:outline-none focus:ring-red-300 hover:bg-red-600"
        {@rest}
      >
        <%= @text %>
      </a>
    """
  end
end
