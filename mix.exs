defmodule Ramoulade.Mixfile do
  use Mix.Project

  def project do
    [app: :ramoulade,
     version: "0.1.0",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    [extra_applications: [:logger]]
  end

  defp deps do
    [
      {:uri_template, "1.2.0"},
      {:yaml_elixir, "1.3.0"},
      {:yamerl, "~> 0.3.2", [env: :prod, hex: :yamerl, optional: false]}
    ]
  end
end
