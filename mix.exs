defmodule JsonStreamEncoder.Mixfile do
  use Mix.Project

  def project do
    [
      app: :json_stream_encoder,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps(),
      description: "A simple interface for streaming JSON to IO.",
      dialyzer: [
        plt_add_deps: :apps_direct,
        plt_add_apps: [
          :compiler, :elixir, :kernel, :logger, :stdlib,
        ]
      ],
      package: package()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    []
  end

  defp package() do
    [
      licenses: ["MIT"],
      maintainers: ["Trey Evans"],
      source_url: "https://github.com/TreyE/json_stream_encoder",
      links: %{"GitHub" => "https://github.com/TreyE/json_stream_encoder"}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:poison, "~> 3.1"},
      {:ex_doc, "~> 0.16", only: :dev, runtime: false},
      {:dialyxir, "~> 0.5", only: [:dev], runtime: false}
    ]
  end
end
