# Emulator Architecture

## Purpose

The emulator provides an in-process, Agent-backed mock of Mnesia tables for testing. It allows tests to exercise table CRUD logic without starting a real Mnesia instance, managing scenarios and tracking call history.

## Components

| Module | Role |
|--------|------|
| `Amnesia.Emulator` | Entry point — `use Amnesia.Emulator` generates start/session/state functions |
| `Amnesia.Emulator.Database` | Macro for defining emulated databases |
| `Amnesia.Emulator.Table` | Emulated table struct (records, state, history) |
| `Amnesia.Emulator.Table.Mock` | Mock table operations — intercepts reads/writes/deletes |
| `Amnesia.Emulator.Table.Record` | Record wrapper tracking existence and history |
| `Amnesia.Emulator.Records` | Record type definitions for emulator sessions |

## Design

Each emulator instance is an `Agent` process holding an `%Amnesia.Emulator{}` struct:

```elixir
%Amnesia.Emulator{
  tables: %{TableName => %{records: %{}, state: :false, history: []}},
  event: 0,
  history: []
}
```

### Sessions and Scenarios

- **Scenario**: A named test context (default: `:default`)
- **Session**: A `emulator_session` record stored in the process dictionary, scoped to `{module, scenario}`
- **Handle**: A globally-registered `{module, scenario, slice}` tuple for Agent identification

### History Tracking

The emulator records call history at three levels:
1. **Global** — all operations across all tables
2. **Per-table** — operations on a specific table
3. **Per-record** — operations on a specific key within a table

This enables test assertions like "verify that `read` was called on key X".

### State Management

Table state can be set via `__set_table_state__/2` to simulate table availability/unavailability scenarios (e.g., table not yet created, table loading).
