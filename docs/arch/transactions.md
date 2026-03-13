# Transaction Model

## Execution Contexts

Amnesia exposes five execution contexts, each mapping to a Mnesia activity mode:

| Context | Mnesia Call | Semantics |
|---------|-------------|-----------|
| `transaction do ... end` | `:mnesia.transaction/1` | Full ACID transaction with locks |
| `transaction! do ... end` | `:mnesia.sync_transaction/1` | Synchronous — waits for writes to propagate |
| `async do ... end` | `:mnesia.async_dirty/1` | Dirty async — no transaction, no locks |
| `sync do ... end` | `:mnesia.sync_dirty/1` | Dirty sync — waits for propagation, no locks |
| `ets do ... end` | `:mnesia.ets/1` | Direct ETS access — fastest, no replication |

All contexts accept both block syntax (`do: ...`) and function/args syntax.

## Dirty Operations (`!` suffix)

Table-level operations use `!` to denote dirty (non-transactional) access:
- `Table.read!(key)` → `mnesia:dirty_read`
- `Table.write!(record)` → `mnesia:dirty_write`
- `Table.delete!(key)` → `mnesia:dirty_delete`

These bypass transaction overhead but sacrifice atomicity and isolation.

## Lock Modes

| Amnesia | Mnesia |
|---------|--------|
| `:read` | `:read` |
| `:write` | `:write` |
| `:write!` | `:sticky_write` |

Sticky write locks persist across transactions for performance on frequently-written records.

## Custom Access Modules

`Amnesia.Access` defines a behaviour matching Mnesia's access module interface. Modules implementing this behaviour can be used with `mnesia:activity/4` to customize how operations are dispatched — this is how Mnesia's built-in fragmentation (`mnesia_frag`) works.

Using `use Amnesia.Access` in a module injects transaction/sync/async/ets macros that route through `mnesia:activity` with the custom access module.

## Result Handling

All Mnesia results go through `Amnesia.Helper.result/1` which normalizes `{:atomic, value}` to the unwrapped value and `{:aborted, reason}` to `{:error, reason}`.
