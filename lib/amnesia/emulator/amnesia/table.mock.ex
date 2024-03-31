#            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#                    Version 2, December 2004
#
#            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#   TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION
#
#  0. You just DO WHAT THE FUCK YOU WANT TO.

defmodule  Amnesia.Emulator.Table.Mock do
  require Amnesia.Emulator.Records
  import Amnesia.Emulator.Records
  #Record.defrecord(:record_state, [record: nil, exists?: true, history: []])
  #Record.defrecord(:table_state, [records: %{}, state: :online, history: []])
  @blank_record %{record: nil, exists?: false, history: []}
  @blank_table %{records: %{}, state: :online, history: []}

  def __set_state__(config = emulator_session(emulator: emulator, table: table), state) do
    Agent.update(apply(emulator, :emulator_handle, [config]), fn(state) ->
      #&(put_in(&1, [Access.key(:tables), table], data))
      event = state.event + 1
      state
      |> add_event(event, {:table_status, {table, state}})
      |> add_table_event(table, event, {:table_status, state})
      |> update_in([Access.key(:tables), table, Access.key(:state)], state)
    end)
  end

  defp set_record_exists(state, table, key, exists? \\ true) do
    state
    |> update_in([Access.key(:tables), table], &(&1 || %Amnesia.Emulator.Table{}))
    |> update_in([Access.key(:tables), table, Access.key(:records), key], &(&1 || %Amnesia.Emulator.Table.Record{}))
    |> put_in([Access.key(:tables), table, Access.key(:records), key, Access.key(:exists?)], exists?)
  end
  defp add_event(state, event_number, event) do
    state
    |> update_in([Access.key(:history)], &(&1 ++ [{event_number, event}]))
    |> put_in([Access.key(:event)], event_number)
  end
  defp add_table_event(state, table, event_number, event) do
    state
    |> update_in([Access.key(:tables), table], &(&1 || %Amnesia.Emulator.Table{}))
    |> update_in([Access.key(:tables), table, Access.key(:history)], &(&1 ++ [{event_number, event}]))
    |> put_in([Access.key(:event)], event_number)
  end
  defp add_record_event(state, table, key, event_number, event) do
    state
    |> update_in([Access.key(:tables), table], &(&1 || %Amnesia.Emulator.Table{}))
    |> update_in([Access.key(:tables), table, Access.key(:records), key], &(&1 || %Amnesia.Emulator.Table.Record{}))
    |> update_in([Access.key(:tables), table, Access.key(:records), key, Access.key(:history)], &(&1 ++ [{event_number, event}]))
    |> put_in([Access.key(:event)], event_number)
  end


  #-----------------------------
  #
  #-----------------------------
  def keys!(mock_configuration = emulator_session(emulator: emulator, table: table)) do
    Agent.get_and_update(apply(emulator, :emulator_handle, [mock_configuration]), fn(state) ->
      event = state.event + 1
      state = state
              |> add_event(event, {:keys!, {table}})
              |> add_table_event(table, event, {:keys!})

      records = get_in(state, [Access.key(:tables), table, Access.key(:records)])
      keys = Map.keys(records)
      {keys, state}
    end)
  end

  def keys(mock_configuration = emulator_session(emulator: emulator, table: table)) do
    Agent.get_and_update(apply(emulator, :emulator_handle, [mock_configuration]), fn(state) ->
      event = state.event + 1
      state = state
              |> add_event(event, {:keys, {table}})
              |> add_table_event(table, event, {:keys})

      records = get_in(state, [Access.key(:tables), table, Access.key(:records)])
      keys = Map.keys(records)
      {keys, state}
    end)
  end

  #-----------------------------
  #
  #-----------------------------
  def write!(mock_configuration = emulator_session(table: table, table_settings: settings), record) do
    key_field = (settings[:key] || List.first(table.info(:attributes)))
    key = get_in(record, [Access.key(key_field)])
    cond do
      settings[:type] == :bag -> write_bag!(mock_configuration, key, record)
      settings[:type] in [:set, :ordered_set] -> write_set!(mock_configuration, key, record)
      table.properties()[:type] == :bag -> write_bag!(mock_configuration, key, record)
      :else -> write_set!(mock_configuration, key, record)
    end
  end

  #-----------------------------
  #
  #-----------------------------
  def write_set!(mock_configuration = emulator_session(emulator: emulator, table: table), key, record) do
    Agent.update(apply(emulator, :emulator_handle, [mock_configuration]), fn(state) ->
      event = state.event + 1
      state
      |> add_event(event, {:write!, {table, key}})
      |> add_table_event(table, event, {:write!, key})
      |> add_record_event(table, key, event, {:write!, record})
      |> put_in([Access.key(:tables), table, Access.key(:records), key, Access.key(:record)], record)
      |> set_record_exists(table, key)
    end)
    record
  end

  #-----------------------------
  #
  #-----------------------------
  @doc """
  Amnesia Method Stub
  """
  def write_bag!(mock_configuration = emulator_session(emulator: emulator, table: table), key, record) do
    Agent.update(apply(emulator, :emulator_handle, [mock_configuration]), fn(state) ->
      event = state.event + 1
      state
      |> add_event(event, {:write!, {table, key}})
      |> add_table_event(table, event, {:write!, key})
      |> add_record_event(table, key, event, {:write!, record})
      |> update_in([Access.key(:tables), table, Access.key(:records), key, Access.key(:record)], &(Enum.uniq((&1 || []) ++ [record])))
      |> set_record_exists(table, key)
    end)
    record
  end

  def write(mock_configuration = emulator_session(table: table, table_settings: settings), record) do
    key_field = (settings[:key] || List.first(table.info(:attributes)))
    key = get_in(record, [Access.key(key_field)])
    cond do
      settings[:type] == :bag -> write_bag(mock_configuration, key, record)
      settings[:type] in [:set, :ordered_set] -> write_set(mock_configuration, key, record)
      table.properties()[:type] == :bag -> write_bag(mock_configuration, key, record)
      :else -> write_set(mock_configuration, key, record)
    end
  end

  #-----------------------------
  #
  #-----------------------------
  def write_set(mock_configuration = emulator_session(emulator: emulator, table: table), key, record) do
    Agent.update(apply(emulator, :emulator_handle, [mock_configuration]), fn(state) ->
      event = state.event + 1
      state
      |> add_event(event, {:write, {table, key}})
      |> add_table_event(table, event, {:write, key})
      |> add_record_event(table, key, event, {:write, record})
      |> put_in([Access.key(:tables), table, Access.key(:records), key, Access.key(:record)], record)
      |> set_record_exists(table, key)
    end)
    record
  end

  #-----------------------------
  #
  #-----------------------------
  @doc """
  Amnesia Method Stub
  """
  def write_bag(mock_configuration = emulator_session(emulator: emulator, table: table), key, record) do
    Agent.update(apply(emulator, :emulator_handle, [mock_configuration]), fn(state) ->
      event = state.event + 1
      state
      |> add_event(event, {:write, {table, key}})
      |> add_table_event(table, event, {:write, key})
      |> add_record_event(table, key, event, {:write, record})
      |> update_in([Access.key(:tables), table, Access.key(:records), key, Access.key(:record)], &(Enum.uniq((&1 || []) ++ [record])))
      |> set_record_exists(table, key)
    end)
    record
  end

  #-----------------------------
  #
  #-----------------------------
  @doc """
  Amnesia Method Stub
  """
  def delete!(mock_configuration = emulator_session(emulator: emulator, table: table, table_settings: settings), record) do
    key_field = (settings[:key] || List.first(table.info(:attributes)))
    key = get_in(record, [Access.key(key_field)])
    Agent.update(apply(emulator, :emulator_handle, [mock_configuration]), fn(state) ->
      event = state.event + 1
      state
      |> add_event(event, {:delete!, {table, key}})
      |> add_table_event(table, event, {:delete!, key})
      |> add_record_event(table, key, event, :delete!)
      |> put_in([Access.key(:tables), table, Access.key(:records), key, Access.key(:record)], nil)
      |> set_record_exists(table, key, false)
    end)
  end
  def delete(mock_configuration = emulator_session(emulator: emulator, table: table, table_settings: settings), record) do
    key_field = (settings[:key] || List.first(table.info(:attributes)))
    key = get_in(record, [Access.key(key_field)])
    Agent.update(apply(emulator, :emulator_handle, [mock_configuration]), fn(state) ->
      event = state.event + 1

      state
      |> add_event(event, {:delete, {table, key}})
      |> add_table_event(table, event, {:delete, key})
      |> add_record_event(table, key, event, :delete)
      |> put_in([Access.key(:tables), table, Access.key(:records), key, Access.key(:record)], nil)
      |> set_record_exists(table, key, false)
    end)
  end

  #-----------------------------
  #
  #-----------------------------
  @doc """
  Amnesia Method Stub
  """
  def read!(mock_configuration = emulator_session(emulator: emulator, table: table), key) do
    Agent.get_and_update(apply(emulator, :emulator_handle, [mock_configuration]), fn(state) ->
      event = state.event + 1
      state = state
              |> add_event(event, {:read!, {table, key}})
              |> add_table_event(table, event, {:read!, key})
              |> add_record_event(table, key, event, :read!)
      {get_in(state, [Access.key(:tables), table, Access.key(:records), key, Access.key(:record)]), state}
    end)
  end
  def read(mock_configuration = emulator_session(emulator: emulator, table: table), key) do
    Agent.get_and_update(apply(emulator, :emulator_handle, [mock_configuration]), fn(state) ->
      event = state.event + 1
      state = state
              |> add_event(event, {:read, {table, key}})
              |> add_table_event(table, event, {:read, key})
              |> add_record_event(table, key, event, :read)
      {get_in(state, [Access.key(:tables), table, Access.key(:records), key, Access.key(:record)]), state}
    end)
  end

  #-----------------------------
  #
  #-----------------------------
  @doc """
  Amnesia Method Stub
  """
  def match!(mock_configuration = emulator_session(emulator: emulator, table: table, table_settings: settings), pattern) do
    values = Agent.get_and_update(apply(emulator, :emulator_handle, [mock_configuration]), fn(state) ->
      key_field = (settings[:key] || List.first(table.info(:attributes)))

      event = state.event + 1
      state = state
              |> add_event(event, {:match!, {table, pattern}})
              |> add_table_event(table, event, {:match!, pattern})

      return = (get_in(state, [Access.key(:tables), table, Access.key(:records)]))
               |> Enum.filter(&( partial_compare( elem(&1, 1).record, pattern)))
               |> Enum.map(&(table.coerce(elem(&1,1).record)))
      state = Enum.reduce(return, state, fn(record, state) ->
        key = get_in(record, [Access.key(key_field)])
        state
        |> add_record_event(table, key, event, {:match!, pattern})
      end)
      {return, state}
    end)
    %Amnesia.Table.Select{values: values, coerce: table}
  end
  def match(mock_configuration = emulator_session(emulator: emulator, table: table, table_settings: settings), pattern) do
    values = Agent.get_and_update(apply(emulator, :emulator_handle, [mock_configuration]), fn(state) ->
      key_field = (settings[:key] || List.first(table.info(:attributes)))

      event = state.event + 1
      state = state
              |> add_event(event, {:match, {table, pattern}})
              |> add_table_event(table, event, {:match, pattern})

      return = (get_in(state, [Access.key(:tables), table, Access.key(:records)]))
               |> Enum.filter(&( partial_compare( elem(&1, 1).record, pattern)))
               |> Enum.map(&(table.coerce(elem(&1,1).record)))
      state = Enum.reduce(return, state, fn(record, state) ->
        key = get_in(record, [Access.key(key_field)])
        state
        |> add_record_event(table, key, event, {:match, pattern})
      end)
      {return, state}
    end)
    %Amnesia.Table.Select{values: values, coerce: table}
  end

  #-----------------------------
  #
  #-----------------------------
  @doc """
  Emulate match functionality.
  """
  def partial_compare(_, :_), do: true
  def partial_compare(v, p) when is_atom(p) do
    cond do
      v == p -> true
      String.starts_with?(Atom.to_string(p), "$") -> true
      :else -> false
    end
  end
  def partial_compare(v, p) when is_tuple(p) do
    cond do
      v == p -> true
      !is_tuple(v) -> false
      tuple_size(v) != tuple_size(p) -> false
      :else ->
        vl = Tuple.to_list(v)
        pl = Tuple.to_list(p)
        Enum.reduce(1..tuple_size(v), true, fn(i,a) ->
          a && partial_compare(Enum.at(vl, i), Enum.at(pl, i))
        end)
    end
  end
  def partial_compare(v, p) when is_list(p) and is_list(v) do
    cond do
      length(v) != length(p) -> false
      v == p -> true
      :else ->
        Enum.reduce(1..length(v), true, fn(i,a) ->
          a && partial_compare(Enum.at(v, i), Enum.at(p, i))
        end)
    end
  end
  def partial_compare(v, p) when is_list(p) and is_map(v) do
    Enum.reduce(p, true, fn({f,fp},a) ->
      cond do
        !a -> a
        !Map.has_key?(v, f) -> false
        v = partial_compare(Map.get(v, f), fp) -> v
        :else -> false
      end
    end)
  end
  def partial_compare(v, p) when is_map(p) and is_map(v) do
    Enum.reduce(p, true, fn({f,fp},a) ->
      cond do
        !a -> a
        !Map.has_key?(v, f) -> false
        v = partial_compare(Map.get(v, f), fp) -> v
        :else -> false
      end
    end)
  end
  def partial_compare(v, p) do
    v == p
  end
end
