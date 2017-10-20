defmodule JsonStreamEncoder.Mixfile do
  use Mix.Project

  def project do
    [
      app: :json_stream_encoder,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps(),
      dialyzer: [
        plt_add_deps: :apps_direct,
        ignore_warnings: "dialyzer.ignore-warnings",
        plt_add_apps: [
          :compiler, :elixir, :kernel, :logger, :stdlib,
          ]]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
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
