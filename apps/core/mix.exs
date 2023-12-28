defmodule Core.MixProject do
  use Mix.Project

  def project do
    [
      app: :core,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "./config/config.exs",
      deps_path: "./../../deps",
      lockfile: "./../../mix.lock",
      elixir: "~> 1.15.0-rc.2",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env())
    ]
  end

  def application do
    [
      extra_applications: [:logger, :mnesia]
    ]
  end

  defp deps do
    [
      {:uuid, "~> 1.1"},
      {:bcrypt_elixir, "~> 3.0"},
      {:joken, "~> 2.5"},
      {:jason, "~> 1.4"},
      {:file_size, "~> 3.0"}
    ]
  end

  defp elixirc_paths(:test), do: [
    "lib",
    "test/shared/fake_adapters",
    "test/confirmation_code/fake_adapters",
    "test/device/fake_adapters",
    "test/user/fake_adapters",
    "test/file/fake_adapters"
  ]
  defp elixirc_paths(_), do: ["lib"]
end
