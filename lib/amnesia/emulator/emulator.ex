#            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#                    Version 2, December 2004
#
#            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#   TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION
#
#  0. You just DO WHAT THE FUCK YOU WANT TO.

defmodule Amnesia.Emulator do

  defstruct [
    tables: %{},
    event: 0,
    history: []
  ]


  defmacro __using__(options \\ []) do
    quote location: :keep do
      require Amnesia.Emulator
      import Amnesia.Emulator
      require Amnesia.Emulator.Database
      import Amnesia.Emulator.Database

      use Agent
      require Amnesia.Emulator.Records
      import Amnesia.Emulator.Records

      def start(scenario \\ :default, settings \\ []) do
        session = init_session(scenario, settings)
        handle = emulator_handle(session)
        Process.put({__MODULE__, :scenario}, scenario)
        Agent.start_link(fn() -> %Amnesia.Emulator{} end, name: handle)
      end

      defp init_session(scenario, settings) do
        slice = {self(), :os.system_time(:millisecond)}
        session = emulator_session(emulator: __MODULE__, scenario: scenario, slice: slice, settings: settings)
        Process.put({__MODULE__, scenario}, session)
        session
      end

      def scenario() do
        Process.get({__MODULE__, :scenario})
      end

      def session(scenario) do
        Process.get({__MODULE__, scenario})
      end

      def emulator_handle() do
        emulator_handle(session(scenario()))
      end
      def emulator_handle(emulator_session(scenario: scenario, slice: slice)) do
        {:global, {__MODULE__, scenario, slice}}
      end

      #-----------------------------
      # Internal State Manipulation
      #-----------------------------
      @doc """
      Get Emulated Table State
      """
      def __table__(table), do: Agent.get(emulator_handle(), &(&1.tables[table] || %{records: %{}, state: :false, history: []}))

      def __init_table__(config = emulator_session(table: table), data) do
        Agent.update(emulator_handle(config), &(put_in(&1, [Access.key(:tables), table], data)))
      end

      def __set_table_state__(config = emulator_session(table: table), status) do
        Amnesia.Emulator.Table.Mock.__set_state__(config, status)
      end

      @doc """
      Get Emulator State
      """
      def __emulator__(), do: Agent.get(emulator_handle(), &(&1))


      @doc """
      Get Emulated Table Record State
      """
      def __record__(table, key) do
        Agent.get(
          emulator_handle(),
          &(get_in(&1, [Access.key(:tables, %{}), Access.key(table, %{}), Access.key(:records, %{}), key]) || %Amnesia.Emulator.Table.Record{exists?: false})
        )
      end

      @doc """
      Get Call History
      """
      def __history__() do
        Agent.get(
          emulator_handle(),
          &(get_in(&1, [Access.key(:history, [])]))
        )
      end

      @doc """
      Get Table Call History
      """
      def __table_history__(table) do
        Agent.get(
          emulator_handle(),
          &((get_in(&1, [Access.key(:tables, %{}), Access.key(table)]) || %Amnesia.Emulator.Table{}).history)
        )
      end

      @doc """
      Get Record Call History
      """
      def __record_history__(table, key) do
        Agent.get(
          emulator_handle(),
          &((get_in(&1, [Access.key(:tables, %{}), Access.key(table, %{}), Access.key(:records, %{}), key]) || %Amnesia.Emulator.Table.Record{exists?: false}).history)
        )
      end


    end
  end

end
