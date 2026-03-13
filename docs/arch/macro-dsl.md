# Macro DSL Architecture

## defdatabase

`defdatabase Name do ... end` (in `Amnesia`) delegates to `Amnesia.Database.defdatabase!/2`, which generates a module with:

- `tables/0` — list of defined table atoms (accumulated via `@tables`)
- `create/1`, `create!/1` — creates all tables + metadata table
- `destroy/0`, `destroy!/0` — drops all tables + metadata
- `wait/1` — waits for all tables to load
- `metadata/0` — returns `Amnesia.Metadata` struct for counter/autoincrement support
- `__using__/1` — aliases and requires all tables for convenient `use Database`

## deftable

`deftable Name, [:field1, :field2], opts` (in `Amnesia.Database`) delegates to `Amnesia.Table.Definition.define/4`, which generates:

### Struct
A `defstruct` matching the attribute list. Fields can have default values or be tagged `autoincrement`.

### Coercion
`coerce/1` converts between `%Table{}` structs and `{TableName, field1, field2, ...}` Mnesia tuples. All read operations coerce results; all write operations coerce structs before passing to Mnesia.

### CRUD Functions
Each function comes in transactional and dirty (`!`) variants:
- `read/2`, `read!/1` — read by primary key (returns struct or `[struct]` for bags)
- `write/2`, `write!/1` — write struct to table (autoincrement applied first, then hooks)
- `delete/2`, `delete!/1` — delete by key or struct
- `read_at/2`, `read_at!/2` — read by secondary index

### Query Macros
- `where/2` — compiles Elixir expressions to match_specs via Exquisite, runs `mnesia:select`
- `where!/2` — dirty variant
- `match/2`, `match!/1` — pattern-based matching with don't-care values
- `select/1-3`, `select!/1` — raw match_spec interface

### Navigation
`first`, `last`, `next`, `prev` (and dirty `!` variants) for cursor-style iteration.

### Table Management
`create`, `destroy`, `clear`, `transform`, `add_copy`, `move_copy`, `delete_copy`, `add_index`, `delete_index`, `mode`, `copying`, `priority`, `majority`, `lock`, `force`, `wait`.

### Streaming
`stream/1`, `stream!/0` return `Amnesia.Table.Stream` structs implementing `Enumerable`.

### Extensions
When `extensions: :enabled` is set in table options, most CRUD and lifecycle functions become `defoverridable`, allowing the table module to customize behavior.

## Option Mapping

Amnesia maps Elixir-friendly keywords to Mnesia's Erlang options:

| Amnesia | Mnesia |
|---------|--------|
| `:disk` | `:disc_copies` |
| `:disk!` | `:disc_only_copies` |
| `:memory` | `:ram_copies` |
| `:rock!` | `:rocksdb_copies` |
| `:both` | `:read_write` |
| `:read!` | `:read_only` |
| `:write!` | `:sticky_write` |
| `:priority` | `:load_order` |
| `:user` | `:user_properties` |
| `:local` | `:local_content` |
