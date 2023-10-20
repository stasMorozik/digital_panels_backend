defmodule AdminPanelWeb.Components.Presentation.Hrefs.ButtonDefault do
  use Phoenix.Component

  alias Phoenix.LiveView.JS
  import AdminPanelWeb.Gettext

  attr :text, :string, required: true
  attr :rest, :global

  def c(assigns) do
    ~H"""
      <a
        class="border-gray-300 text-center text-white bg-blue-500 rounded-md p-2 focus:ring-4 focus:outline-none focus:ring-blue-300 hover:bg-blue-800"
        {@rest}
      >
        <%= @text %>
      </a>
    """
  end
end
