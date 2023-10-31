defmodule AdminPanelWeb.Components.Presentation.Buttons.ButtonAmber do
  use Phoenix.Component

  alias Phoenix.LiveView.JS
  import AdminPanelWeb.Gettext

  attr :text, :string, required: true
  attr :rest, :global

  def c(assigns) do
    ~H"""
      <button
        class="text-center text-white bg-amber-500 rounded-md p-2 focus:ring-4 focus:outline-none focus:ring-amber-300 hover:bg-amber-800"
        {@rest}
      >
        <%= @text %>
      </button>
    """
  end
end
