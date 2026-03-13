defmodule Amnesia.Mixfile do
  use Mix.Project

  def project do
    [ app: :amnesia,
      version: "0.2.12",
      deps: deps(),
      package: package(),
      description: "mnesia wrapper for Elixir",
      elixirc_paths: elixirc_paths(Mix.env)
    ]
  end

  defp package do
    [ maintainers: ["meh"],
      licenses: ["WTFPL"],
      links: %{"GitHub" => "https://github.com/meh/amnesia"} ]
  end

  def application do
    test_deps = Mix.env == :test && [:mock] || []
    [ applications: [:mnesia, :logger, :nexquisite | test_deps] ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  defp deps do
    [
      {:nexquisite, "~> 0.1.11" },
      {:ex_doc, "~> 0.40", only: [:dev] },

      {:sext, "~> 1.8.0", optional: true},
      {:mock, "~> 0.3.1", only: [:test], optional: true},
    ]
  end
end
