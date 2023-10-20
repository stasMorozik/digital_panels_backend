defmodule AdminPanelWeb.Components.Presentation.Hrefs.Link do
  use Phoenix.Component

  alias Phoenix.LiveView.JS
  import AdminPanelWeb.Gettext

  attr :text, :string, required: true
  attr :rest, :global

  def c(assigns) do
    ~H"""
      <a
        class="font-medium text-blue-500 dark:text-blue-500 hover:underline"
        {@rest}
      >
        <%= @text %>
      </a>
    """
  end
end
