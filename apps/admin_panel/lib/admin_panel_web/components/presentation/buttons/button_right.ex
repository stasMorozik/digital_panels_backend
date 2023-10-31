defmodule AdminPanelWeb.Components.Presentation.Buttons.ButtonRight do
  use Phoenix.Component

  alias Phoenix.LiveView.JS
  import AdminPanelWeb.Gettext

  attr :rest, :global

  def c(assigns) do
    ~H"""
      <button
        {@rest}
      >
        <FontAwesome.LiveView.icon name="caret-right" type="solid" class="h-4 w-4"/>
      </button>
    """
  end
end
