defmodule JsonStreamEncoder.Mixfile do
  use Mix.Project

  @version "0.2.0"

  def project do
    [
      app: :json_stream_encoder,
      version: @version,
      elixir: "~> 1.7",
      start_permanent: Mix.env == :prod,
      deps: deps(),
      description: "A simple interface for streaming JSON to IO.",
      dialyzer: [
        plt_add_deps: :apps_direct,
        plt_add_apps: [
          :compiler, :elixir, :kernel, :logger, :stdlib,
        ]
      ],
      package: package(),
      docs: docs()
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
      {:jason, ">= 1.0.0"},
      {:ex_doc, "~> 0.19", only: :dev, runtime: false},
      {:dialyxir, "~> 0.5", only: [:dev], runtime: false}
    ]
  end

  defp docs do
    [
      main: "readme",
      source_ref: "#{@version}",
      source_url: "https://github.com/TreyE/json_stream_encoder",
      extras: ["README.md"]
    ]
  end
end
