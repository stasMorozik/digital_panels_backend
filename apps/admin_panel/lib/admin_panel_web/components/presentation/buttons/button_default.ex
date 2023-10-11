defmodule AdminPanelWeb.Components.Presentation.Buttons.ButtonDefault do
  use Phoenix.Component

  alias Phoenix.LiveView.JS
  import AdminPanelWeb.Gettext

  attr :text, :string, required: true
  attr :rest, :global

  def c(assigns) do
    ~H"""
      <button
        class="text-center text-white bg-violet-500 rounded-md p-1 focus:ring-4 focus:outline-none focus:ring-violet-300 hover:bg-violet-800"
        {@rest}
      >
        <%= @text %>
      </button>
    """
  end
end
