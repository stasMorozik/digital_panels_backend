defmodule AdminPanelWeb.Components.Presentation.Inputs.Text do
  use Phoenix.Component

  alias Phoenix.LiveView.JS
  import AdminPanelWeb.Gettext

  attr :field, Phoenix.HTML.FormField
  attr :rest, :global
  attr :label, :any, required: false, default: false

  def c(assigns) do
    ~H"""
      <%= if @label do %>
        <label class="mb-3 block text-zinc-950">
          <%= @label %>
        </label>
      <% end %>
      <input
        id={@field.id} name={@field.name} value={@field.value}
        type="text"
        class="bg-gray-50 border border-gray-300 text-gray-900 rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full p-2.5 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500"
        {@rest}
      >
    """
  end
end
