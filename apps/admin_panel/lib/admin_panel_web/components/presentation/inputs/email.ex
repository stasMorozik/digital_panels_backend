defmodule AdminPanelWeb.Components.Presentation.Inputs.Email do
  use Phoenix.Component

  alias Phoenix.LiveView.JS
  import AdminPanelWeb.Gettext

  attr :field, Phoenix.HTML.FormField
  attr :rest, :global, include: ~w(type)

  def c(assigns) do
    ~H"""
      <input
        id={@field.id} name={@field.name} value={@field.value}
        type="email"
        class="bg-gray-50 border border-gray-300 text-gray-900 rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full p-2.5 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500"
        {@rest}
      >
    """
  end
end
