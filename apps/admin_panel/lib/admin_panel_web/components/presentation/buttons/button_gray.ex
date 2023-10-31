defmodule AdminPanelWeb.Components.Presentation.Buttons.ButtonGray do
  use Phoenix.Component

  alias Phoenix.LiveView.JS
  import AdminPanelWeb.Gettext

  attr :text, :string, required: true
  attr :rest, :global

  def c(assigns) do
    ~H"""
      <button
        class="text-center text-white bg-slate-500 rounded-md p-2 focus:ring-4 focus:outline-none focus:ring-slate-300 hover:bg-slate-800"
        {@rest}
      >
        <%= @text %>
      </button>
    """
  end
end
