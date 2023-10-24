defmodule AdminPanelWeb.Router do
  use AdminPanelWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {AdminPanelWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", AdminPanelWeb do
    pipe_through :browser

    live_session :for_main_page, on_mount: AdminPanelWeb.AuthForSignInPageLive do
      live "/", SignInByEmailLive
    end

    live_session :for_sign_in_page, on_mount: AdminPanelWeb.AuthForSignInPageLive do
      live "/sign-in", SignInByEmailLive
    end

    live_session :for_not_sign_in_page, on_mount: AdminPanelWeb.AuthForNotSignInPageLive, layout: {AdminPanelWeb.Layouts, :dashboard} do
      live "/devices", DevicesLive
      live "/device/new", DeviceNewLive
      live "/playlists", PlaylistsLive
      live "/playlist/new", PlaylistNewLive
      live "/statistic", StatisticLive
    end
  end

  if Application.compile_env(:admin_panel, :dev_routes) do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: AdminPanelWeb.Telemetry
    end
  end
end
