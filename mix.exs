defmodule Amnesia.Mixfile do
  use Mix.Project

  def project do
    [ app: :amnesia,
      version: "0.2.8",
      deps: deps(),
      package: package(),
      description: "mnesia wrapper for Elixir" ]
  end

  defp package do
    [ maintainers: ["meh"],
      licenses: ["WTFPL"],
      links: %{"GitHub" => "https://github.com/meh/amnesia"} ]
  end

  def application do
    [ applications: [:mnesia, :logger, :exquisite] ]
  end

  defp deps do
    [
      {:exquisite, git: "https://github.com/noizu/exquisite.git", ref: "61d48f8", override: true},
      #{ :exquisite, "~> 0.1.7" },
  
      {:sext, "~> 1.8.0", optional: true},
      {:mnesia_rocksdb, github: "aeternity/mnesia_rocksdb", ref: "ab15b7f3990", optional: true},
      
      { :ex_doc, "~> 0.15", only: [:dev] } ]
  end
end
