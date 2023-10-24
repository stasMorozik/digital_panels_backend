defmodule AdminPanelWeb.Components.Presentation.Inputs.Hidden do
  use Phoenix.Component

  alias Phoenix.LiveView.JS
  import AdminPanelWeb.Gettext

  attr :field, Phoenix.HTML.FormField
  attr :rest, :global

  def c(assigns) do
    ~H"""
      <input
        id={@field.id} name={@field.name} value={@field.value}
        type="hidden"
        {@rest}
      >
    """
  end
end
