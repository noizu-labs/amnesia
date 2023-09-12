#            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#                    Version 2, December 2004
#
#            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#   TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION
#
#  0. You just DO WHAT THE FUCK YOU WANT TO.

defmodule Amnesia.Emulator.Database do
  defstruct [
    tables: %{},
    history: []
  ]

  defmacro mockdatabase(name, options \\ [], [do: block]) do
    quote do
      db = unquote(options[:database] || name)
      parent = __MODULE__
      defmodule unquote(name) do
        @base parent
        require Amnesia.Emulator.Records
        import Amnesia.Emulator.Records
        require Elixir.Amnesia.Emulator.Table
        import Elixir.Amnesia.Emulator.Table
        @database db
        Module.register_attribute(__MODULE__, :tables, accumulate: true)


        def mock(scenario \\ :default) do
          {@database, [:passthrough], __mock_methods__(scenario)}
        end

        def __mock_methods__(scenario \\ :current) do
          scenario = cond do
            scenario == :current -> apply(@base, :scenario, [])
            :else -> scenario
          end
          settings = apply(@base, :session, [scenario])
          [
            tables: fn() -> tables(settings) end
          ]
        end

        unquote(block)

        def tables(_settings), do: tables()
        def tables(), do: @tables
      end
    end
  end
end
