# Architecture Summary

Amnesia (`:nuamnesia`) — Elixir macro DSL wrapping Erlang's Mnesia distributed database.

## Core Components

- **Amnesia** — Entry point, `defdatabase` macro, transaction helpers, start/stop
- **Amnesia.Database** — `deftable` macro, database lifecycle (create/destroy/wait)
- **Amnesia.Table** — Low-level Mnesia CRUD, locking, copying, indexing
- **Amnesia.Table.Definition** — Code generation for table modules (struct, CRUD, queries, hooks)
- **Amnesia.Hooks** — Overridable lifecycle callbacks on table records
- **Amnesia.Access** — Behaviour for custom `mnesia:activity` access modules
- **Amnesia.Emulator** — Agent-based Mnesia mock for testing
- **Amnesia.Schema** — Mnesia schema create/destroy

## Architecture Pattern

Macro-generated modules: `defdatabase` + `deftable` generate full Elixir modules with structs, CRUD, query macros, and hooks. Records auto-coerce between Elixir structs and Mnesia tuples.

## Transaction Contexts

Five modes: `transaction`, `transaction!` (sync), `async` (dirty), `sync` (dirty sync), `ets`. Functions with `!` suffix use dirty (non-transactional) operations.

## Storage Backends

`:memory` (RAM), `:disk` (disc_copies), `:disk!` (disc_only), `:rock!` (RocksDB, optional).

## Key Dependencies

Exquisite (`nexquisite`) for compile-time match_spec generation, optional `mnesia_rocksdb` for RocksDB backend.
