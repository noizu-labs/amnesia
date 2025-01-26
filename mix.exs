defmodule Amnesia.Mixfile do
  use Mix.Project

  def project do
    [ app: :nuamnesia,
      version: "0.3.0",
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
    [ 
      applications: [],
      extra_applications: [:logger, :mnesia, :exquisite, :ex_doc | test_deps]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev},
      {:exquisite, "~> 0.1.10" },
      {:sext, "~> 1.8.0", optional: true},
      #{:mnesia_rocksdb, github: "aeternity/mnesia_rocksdb", ref: "ab15b7f3990", optional: true},
      {:mock, "~> 0.3.1", only: [:test], optional: true},
    ]
  end
end
