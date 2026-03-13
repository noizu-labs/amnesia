defmodule Amnesia.Mixfile do
  use Mix.Project

  def project do
    [ app: :nuamnesia,
      version: "0.3.1",
      deps: deps(),
      package: package(),
      description: "mnesia wrapper for Elixir",
      elixirc_paths: elixirc_paths(Mix.env)
    ]
  end

  defp package do
    [ maintainers: ["noizu"],
      licenses: ["WTFPL"],
      links: %{"GitHub" => "https://github.com/noizu-labs/amnesia"} ]
  end

  def application do
    test_deps = Mix.env == :test && [:mock] || []
    [ extra_applications: [:mnesia, :logger | test_deps] ]
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
