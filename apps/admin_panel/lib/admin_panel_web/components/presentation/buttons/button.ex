defmodule AdminPanelWeb.Components.Presentation.Buttons.Button do
  use Phoenix.Component

  alias Phoenix.LiveView.JS
  import AdminPanelWeb.Gettext

  attr :text, :string, required: true
  attr :rest, :global

  def c(assigns) do
    ~H"""
      <button
        class="dark:bg-blue-600 dark:hover:bg-blue-700 dark:focus:ring-blue-800 text-center text-white bg-violet-500 rounded-md p-2 focus:ring-4 focus:outline-none focus:ring-blue-300"
        {@rest}
      >
        <%= @text %>
      </button>
    """
  end
end
