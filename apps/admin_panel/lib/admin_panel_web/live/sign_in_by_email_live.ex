defmodule AdminPanelWeb.SignInByEmailLive do
  use AdminPanelWeb, :live_view

  require Logger

  alias Core.ConfirmationCode.UseCases.Creating
  alias PostgresqlAdapters.ConfirmationCode.Inserting
  alias SmtpAdapters.Notifier

  alias Core.User.UseCases.Authentication
  alias PostgresqlAdapters.ConfirmationCode.Getting, as: GetterCode
  alias PostgresqlAdapters.User.Getting, as: GetterUser

  alias Core.ConfirmationCode.UseCases.Confirming
  alias PostgresqlAdapters.ConfirmationCode.UpdatingConfirmed

  def mount(_params, session, socket) do
    {
      :ok,
      assign(socket, :state, %{
        success_sending_confirmation_code: nil,
        success_confirm_confirmation_code: nil,
        error: nil,
        form: to_form( %{email: "", code: "", csrf_token: Map.get(session, "_csrf_token", "")} )
      })
    }
  end

  def render(assigns) do
    ~H"""
      <div class="font-bold mt-12 w-1/3 m-auto text-center">Вход в панель администратора</div>
      <%= if @state.success_sending_confirmation_code != true do %>
        <.form class="mt-8 p-8 rounded w-1/3 m-auto" for={@state.form} phx-submit="send_confirmation_code">
          <%= if @state.success_sending_confirmation_code == false do %>
            <AdminPanelWeb.Components.Presentation.Alerts.Warning.c
              message={@state.error}
              id="alert"
            />
          <% end %>
          <AdminPanelWeb.Components.Presentation.Inputs.Email.c
            field={@state.form[:email]}
            required
            autocomplete="off"
            placeholder="Через адрес электронной почты"
          />
          <AdminPanelWeb.Components.Presentation.Inputs.Hidden.c
            field={@state.form[:csrf_token]}
            value={@state.form.params.csrf_token}
            required
          />
          <br>
          <AdminPanelWeb.Components.Presentation.Buttons.ButtonDefault.c
            type="submit"
            text="Продолжить"
          />
        </.form>
      <% end %>
      <%= if @state.success_sending_confirmation_code == true do %>
        <.form class="mt-8 p-8 rounded w-1/3 m-auto" for={@state.form} phx-submit="sign_in">
          <%= if @state.success_confirm_confirmation_code == false do %>
            <AdminPanelWeb.Components.Presentation.Alerts.Warning.c
              message={@state.error}
              id="alert"
            />
          <% end %>
          <AdminPanelWeb.Components.Presentation.Inputs.Hidden.c
            field={@state.form[:email]}
            value={@state.form.params.email}
            required
          />
          <AdminPanelWeb.Components.Presentation.Inputs.Hidden.c
            field={@state.form[:csrf_token]}
            value={@state.form.params.csrf_token}
            required
          />
          <AdminPanelWeb.Components.Presentation.Inputs.Text.c
            field={@state.form[:code]}
            required
            autocomplete="off"
            placeholder="Введите код который мы выслали вам на почту"
          />
          <br>
          <AdminPanelWeb.Components.Presentation.Buttons.ButtonDefault.c
            type="submit"
            text="Войти"
          />
        </.form>
      <% end %>
      <div class="w-1/3 m-auto p-8">
        <AdminPanelWeb.Components.Presentation.Hrefs.Link.c
          href="#"
          text="Запросить доступ"
        />
      </div>
    """
  end

  def handle_event("send_confirmation_code", form, socket) do
    case Creating.create( Inserting, Notifier, Map.get(form, "email") ) do
      {:ok, _} ->

        email = Map.get(form, "email")

        {
          :noreply,
          assign(socket, :state, %{
            success_sending_confirmation_code: true,
            success_confirm_confirmation_code: nil,
            error: nil,
            form: to_form( %{email: email, code: "", csrf_token: Map.get(form, "csrf_token")} )
          })
        }
      {:error, message} ->
        {
          :noreply,
          assign(socket, :state, %{
            success_sending_confirmation_code: false,
            success_confirm_confirmation_code: nil,
            error: message,
            form: to_form( %{email: "", code: "", csrf_token: Map.get(form, "csrf_token")} )
          })
        }
    end
  end

  def handle_event("sign_in", form, socket) do
    email = Map.get(form, "email")
    code = Map.get(form, "code")

    args = %{needle: email, code: String.to_integer(code)}

    case Confirming.confirm(UpdatingConfirmed, GetterCode, args) do
      {:ok, _} ->

        args = %{email: email}

        case Authentication.auth(GetterCode, GetterUser, args) do
          {:ok, tokens} ->

            :ets.insert(:access_tokens, {Map.get(form, "csrf_token"), "", tokens.access_token})
            :ets.insert(:refresh_tokens, {Map.get(form, "csrf_token"), "", tokens.refresh_token})

            {:noreply, push_redirect(socket, to: "/devices")}
          {:error, message} ->

            {
              :noreply,
              assign(socket, :state, %{
                success_sending_confirmation_code: false,
                success_confirm_confirmation_code: nil,
                error: message,
                form: to_form( %{email: "", code: "", csrf_token: Map.get(form, "csrf_token")} )
              })
            }
        end
      {:error, message} ->

        {
          :noreply,
          assign(socket, :state, %{
            success_sending_confirmation_code: true,
            success_confirm_confirmation_code: false,
            error: message,
            form: to_form( %{email: "", code: "", csrf_token: Map.get(form, "csrf_token")} )
          })
        }
    end
  end
end
