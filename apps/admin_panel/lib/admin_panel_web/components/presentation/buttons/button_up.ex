defmodule AdminPanelWeb.Components.Presentation.Buttons.ButtonUp do
  use Phoenix.Component

  alias Phoenix.LiveView.JS
  import AdminPanelWeb.Gettext

  attr :rest, :global

  def c(assigns) do
    ~H"""
      <button
        class="text-center text-white bg-slate-100 rounded-md p-2 focus:ring-4 focus:outline-none focus:ring-slate-300 hover:bg-slate-100 border border-slate "
        {@rest}
      >
        <FontAwesome.LiveView.icon 
          name="angle-up" 
          type="solid" 
          class="h-4 w-4 text-blue-800"
        />
      </button>
    """
  end
end
