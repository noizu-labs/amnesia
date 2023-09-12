defmodule Amnesia.Mixfile do
  use Mix.Project

  def project do
    [ app: :amnesia,
      version: "0.2.9",
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
    [ applications: [:mnesia, :logger, :exquisite] ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  defp deps do
    [
      {:exquisite, "~> 0.1.10" },
      { :ex_doc, "~> 0.15", only: [:dev] },

      {:sext, "~> 1.8.0", optional: true},
      {:mnesia_rocksdb, github: "aeternity/mnesia_rocksdb", ref: "ab15b7f3990", optional: true},
      {:mock, "~> 0.3.1", optional: true},
    ]
  end
end
