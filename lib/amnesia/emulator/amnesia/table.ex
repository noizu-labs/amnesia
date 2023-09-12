#            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#                    Version 2, December 2004
#
#            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#   TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION
#
#  0. You just DO WHAT THE FUCK YOU WANT TO.

defmodule Amnesia.Emulator.Table do
  defstruct [
    records: %{},
    history: [],
    state: :online
  ]

  defmodule Record do
    defstruct [
      record: nil,
      exists?: true,
      history: []
    ]
  end

  defmacro default_scenario([do: block]) do
    quote do
      def initial_data(:default) do
        unquote(block)
      end
    end
  end
  defmacro scenario(name, [do: block]) do
    quote do
      def initial_data(unquote(name)) do
        unquote(block)
      end
    end
  end

  defmacro mocktable(name, [do: block]) do
    quote location: :keep do
      table = Module.concat([@database, unquote(name)])
      @tables table
      parent = @base
      defmodule unquote(name) do
        @table table
        @base parent
        def mock(scenario \\ :current, settings \\ []) do
          scenario = cond do
            scenario == :current -> apply(@base, :scenario, [])
            :else -> scenario
          end
          mock_configuration = emulator_session(
            apply(@base, :session, [scenario]),
            table: @table,
            table_settings: settings
          )

          # Set Data
          load_table(mock_configuration)

          {@table, [:passthrough], __mock_methods__(mock_configuration)}
        end

        defp load_table(config = emulator_session(table: table, table_settings: settings, scenario: scenario)) do
          key_field = (settings[:key] || List.first(table.info(:attributes)))
          data = initial_data(scenario)
                 |> Enum.map(
                      fn(record) ->
                        {
                          get_in(record, [Access.key(key_field)]),
                          %Amnesia.Emulator.Table.Record{record: record}
                        }
                      end
                    )
                 |> Map.new()
          init = %Amnesia.Emulator.Table{
            records: data,
            state: settings[:state] || :online,
            history: []
          }

          apply(@base, :__init_table__, [config, init])
        end

        def __mock_methods__(mock_configuration) do
          [
            read: fn(key) -> read(mock_configuration, key) end,
            read!: fn(key) -> read!(mock_configuration, key) end,
            write: fn(record) -> write(mock_configuration, record) end,
            write!: fn(record) -> write!(mock_configuration, record) end,
            delete: fn(record) -> delete(mock_configuration, record) end,
            delete!: fn(record) -> delete!(mock_configuration, record) end,
            match: fn(selector) -> match(mock_configuration, selector) end,
            match!: fn(selector) -> match!(mock_configuration, selector) end,
          ]
        end

        defdelegate read(settings, key), to: Amnesia.Emulator.Table.Mock
        defdelegate read!(settings, key), to: Amnesia.Emulator.Table.Mock
        defdelegate write(settings, key), to: Amnesia.Emulator.Table.Mock
        defdelegate write!(settings, key), to: Amnesia.Emulator.Table.Mock
        defdelegate delete(settings, key), to: Amnesia.Emulator.Table.Mock
        defdelegate delete!(settings, key), to: Amnesia.Emulator.Table.Mock
        defdelegate match(settings, key), to: Amnesia.Emulator.Table.Mock
        defdelegate match!(settings, key), to: Amnesia.Emulator.Table.Mock


        defoverridable [
          __mock_methods__: 1,
          read: 2,
          read!: 2,
          write: 2,
          write!: 2,
          delete: 2,
          delete!: 2,
          match: 2,
          match!: 2,
        ]

        unquote(block)

        def initial_data(scenario) when scenario not in [:default] do
          initial_data(:default)
        end
        def initial_data(_) do
          []
        end

      end
    end
  end
end
