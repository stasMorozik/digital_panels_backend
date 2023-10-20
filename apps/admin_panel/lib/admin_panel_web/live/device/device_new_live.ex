defmodule AdminPanelWeb.DeviceNewLive do
  use AdminPanelWeb, :live_view

  alias Core.Device.UseCases.Creating
  alias PostgresqlAdapters.Device.Inserting

  alias Core.User.UseCases.Authorization
  alias PostgresqlAdapters.User.GettingById, as: GettingUser
  alias PostgresqlAdapters.Playlist.Getting, as: GettingPlaylist

  def mount(_params, session, socket) do
    socket = assign(socket, :current_page, "devices")

    socket = assign(socket, :state, %{
      playlists: [],
      geting_playlists: false,
      success_creating_device: nil,
      error: nil,
      form: to_form( %{
        address: "",
        ssh_port: "",
        ssh_host: "",
        ssh_user: "",
        ssh_password: "",
        longitude: "",
        latitude: "",
        csrf_token: Map.get(session, "_csrf_token", "")
      })
    })

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
      <%= if @state.geting_playlists == true do %>
        <div phx-click="close_drop_down" class="fixed w-full h-full z-10"></div>
      <% end %>
      <div class="flex flex-row items-center mb-12">
        <h2 class="mr-10 text-lg text-black">Добавление нового устройства</h2>
      </div>
      <div class="mt-12">
        <.form for={@state.form} phx-submit="create_device">
          <%= if @state.success_creating_device == false do %>
            <AdminPanelWeb.Components.Presentation.Alerts.Warning.c
              message={@state.error}
              id="alert"
            />
          <% end %>
          <AdminPanelWeb.Components.Presentation.Inputs.Hidden.c
            field={@state.form[:csrf_token]}
            value={@state.form.params.csrf_token}
            required
          />
          <%= if @state.geting_playlists == false do %>
            <div class="relative">
              <label class="mb-3 block text-zinc-950">
                Плэйлист
              </label>
              <div class="border border-slate rounded-lg p-2 flex justify-end">
                <AdminPanelWeb.Components.Presentation.Buttons.ButtonDown.c 
                  type="button"
                  phx-click="get_playlists"
                />
              </div>
            </div>
          <% end %>
          <%= if @state.geting_playlists == true do %>
            <div class="relative">
              <label class="mb-3 block text-zinc-950">
                Плэйлист
              </label>
              <div class="border border-slate rounded-lg p-2 flex justify-end">
                <AdminPanelWeb.Components.Presentation.Buttons.ButtonUp.c 
                  type="button"
                  phx-click="close_drop_down"
                />
              </div>
              <div class="absolute bg-white border border-slate w-full p-2 rounded-lg mt-1 z-20">
                Test
              </div>
            </div>
          <% end %>
          <br>
          <AdminPanelWeb.Components.Presentation.Inputs.Text.c
            field={@state.form[:address]}
            value={@state.form.params.address}
            required
            autocomplete="off"
            label="Адрес"
            placeholder="Адрес по которому можно найти устройство"
          />
          <br>
          <AdminPanelWeb.Components.Presentation.Inputs.Text.c
            field={@state.form[:latitude]}
            value={@state.form.params.latitude}
            required
            autocomplete="off"
            label="Широта"
            placeholder="Широта по которой можно найти устройство"
          />
          <br>
          <AdminPanelWeb.Components.Presentation.Inputs.Text.c
            field={@state.form[:longitude]}
            value={@state.form.params.longitude}
            required
            autocomplete="off"
            label="Долгота"
            placeholder="Долгота по которой можно найти устройство"
          />
          <br>
          <AdminPanelWeb.Components.Presentation.Inputs.Text.c
            field={@state.form[:ssh_port]}
            value={@state.form.params.ssh_port}
            required
            autocomplete="off"
            placeholder="Порт для подключения по SSH"
            label="Порт SSH"
          />
          <br>
          <AdminPanelWeb.Components.Presentation.Inputs.Text.c
            field={@state.form[:ssh_host]}
            value={@state.form.params.ssh_host}
            required
            autocomplete="off"
            placeholder="Хост для подключения по SSH"
            label="Хост SSH"
          />
          <br>
          <AdminPanelWeb.Components.Presentation.Inputs.Text.c
            field={@state.form[:ssh_user]}
            value={@state.form.params.ssh_user}
            required
            autocomplete="off"
            placeholder="Пользователь для подключения по SSH"
            label="Пользователь SSH"
          />
          <br>
          <AdminPanelWeb.Components.Presentation.Inputs.Text.c
            field={@state.form[:ssh_password]}
            value={@state.form.params.ssh_password}
            required
            autocomplete="off"
            placeholder="Пароль для подключения по SSH"
            label="Пароль SSH"
          />
          <br>
          <AdminPanelWeb.Components.Presentation.Buttons.ButtonDefault.c 
            type="submit" 
            text="Добавить устройство"
          />
          <AdminPanelWeb.Components.Presentation.Hrefs.ButtonWarning.c 
            href="/devices" 
            text="Отмена"
          />
        </.form>
      </div>
    """
  end

  def handle_event("get_playlists", form, socket) do
    {
      :noreply,
      assign(socket, :state, %{
        playlists: [],
        geting_playlists: true,
        success_creating_device: nil,
        error: nil,
        form: to_form( %{
          address: Map.get(form, "address", ""),
          ssh_port: Map.get(form, "ssh_port", ""),
          ssh_host: Map.get(form, "ssh_host", ""),
          ssh_user: Map.get(form, "ssh_user", ""),
          ssh_password: Map.get(form, "ssh_password", ""),
          longitude: Map.get(form, "longitude", ""),
          latitude: Map.get(form, "latitude", ""),
          csrf_token: Map.get(form, "csrf_token", "")
        })
      })
    }
  end

  def handle_event("close_drop_down", form, socket) do
    {
      :noreply,
      assign(socket, :state, %{
        playlists: [],
        geting_playlists: false,
        success_creating_device: nil,
        error: nil,
        form: to_form( %{
          address: Map.get(form, "address", ""),
          ssh_port: Map.get(form, "ssh_port", ""),
          ssh_host: Map.get(form, "ssh_host", ""),
          ssh_user: Map.get(form, "ssh_user", ""),
          ssh_password: Map.get(form, "ssh_password", ""),
          longitude: Map.get(form, "longitude", ""),
          latitude: Map.get(form, "latitude", ""),
          csrf_token: Map.get(form, "csrf_token", "")
        })
      })
    }
  end

  def handle_event("create_device", form, socket) do
    args = %{
      ssh_port: String.to_integer( Map.get(form, "ssh_port", "") ),
      ssh_host: Map.get(form, "ssh_host", ""),
      ssh_user: Map.get(form, "ssh_user", ""),
      ssh_password: Map.get(form, "ssh_password", ""),
      address: Map.get(form, "address", ""),
      longitude: String.to_float(Map.get(form, "longitude", "")),
      latitude: String.to_float(Map.get(form, "latitude", ""))
    }

    csrf_token = Map.get(form, "csrf_token", "")

    with [{_, "", access_token}] <- :ets.lookup(:access_tokens, csrf_token),
         args = Map.put(args, :token, access_token),
         {:ok, _} <- Creating.create(
            Authorization, 
            GettingUser, 
            GettingPlaylist, 
            Inserting, 
            args
          ) do

      Logger.info("Пользователь добавил устройство - #{args}")

      {
        :noreply,
        assign(socket, :state, %{
          playlists: [],
          geting_playlists: false,
          success_creating_device: nil,
          error: "",
          form: to_form( %{
            address: "",
            ssh_port: "",
            ssh_host: "",
            ssh_user: "",
            ssh_password: "",
            longitude: "",
            latitude: "",
            csrf_token: Map.get(form, "csrf_token", "")
          })
        })
      }
    else
      [] -> {:noreply, push_redirect(socket, to: "/sign-in")}
      {:error, message} ->

        Logger.notice(message)

        {
          :noreply,
          assign(socket, :state, %{
            playlists: [],
            geting_playlists: false,
            success_creating_device: false,
            error: message,
            form: to_form( %{
              address: Map.get(form, "address", ""),
              ssh_port: Map.get(form, "ssh_port", ""),
              ssh_host: Map.get(form, "ssh_host", ""),
              ssh_user: Map.get(form, "ssh_user", ""),
              ssh_password: Map.get(form, "ssh_password", ""),
              longitude: Map.get(form, "longitude", ""),
              latitude: Map.get(form, "latitude", ""),
              csrf_token: Map.get(form, "csrf_token", "")
            })
          })
        }
    end
  end
end
