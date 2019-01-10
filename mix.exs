defmodule SendInBlue.MixProject do
  use Mix.Project

  def project do
    [
      app: :sendinbluex,
      deps: deps(),
      description: description(),
      dialyzer: [plt_add_apps: [:mix, :jason]],
      elixir: "~> 1.7",
      elixirc_paths: elixirc_paths(Mix.env()),
      package: package(),
      source_url: "https://github.com/Lean5/sendinbluex",
      version: "0.1.0",
    ]
  end

  def application do
    [
      applications: apps(Mix.env()),
      env: env(),
      mod: {SendInBlue, []}
    ]
  end

  defp apps(:test), do: [:bypass | apps()]
  defp apps(_), do: apps()
  defp apps(), do: [:hackney, :logger]

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp env() do
    [
      api_base_url: "https://api.sendinblue.com/v3/",
      tracker_base_url: "https://in-automate.sendinblue.com/api/v2/",
      pool_options: [
        timeout: 5_000,
        max_connections: 10
      ],
      use_connection_pool: true
    ]
  end

  defp deps do
    [
      {:bypass, "~> 1.0", only: :test},
      {:dialyxir, "~> 0.5", only: [:dev, :test], runtime: false},
      {:hackney, "~> 1.12.1"},
      {:jason, "~> 1.0"},
    ]
  end

  defp description do
    """
    A SendInBlue client for Elixir.
    """
  end
    
  defp package() do
    [
      maintainers: ["Manuel Pöter"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/Lean5/sendinbluex"}
    ]
  end
end
