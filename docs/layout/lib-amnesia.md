# lib/amnesia/ — Core Library

```
amnesia/
├── emulator/                       # Mnesia emulator for testing
│   ├── amnesia/                    # Emulated module implementations
│   │   ├── database.ex             #   Emulated database behaviour
│   │   ├── records.ex              #   Emulated record storage
│   │   ├── table.ex                #   Emulated table operations
│   │   └── table.mock.ex           #   Mock table for test isolation
│   └── emulator.ex                 # Emulator entry point / coordinator
├── fragment/                       # Table fragmentation
│   └── hash.ex                     # Hash-based fragment distribution
├── table/                          # Table operation modules
│   ├── coordinator.ex              # Table creation/lifecycle coordination
│   ├── definition.ex               # Table struct and field definitions
│   ├── match.ex                    # Pattern matching queries
│   ├── select.ex                   # Select-based queries (guard expressions)
│   └── stream.ex                   # Streaming table reads
├── access.ex                       # Transaction/access context helpers
├── backup.ex                       # Mnesia backup/restore wrappers
├── database.ex                     # `defdatabase` macro — defines a database module
├── event.ex                        # Mnesia event subscriptions
├── exceptions.ex                   # Custom exception types
├── fragment.ex                     # Fragment configuration helpers
├── helper.ex                       # Internal utility functions
├── hooks.ex                        # Lifecycle hooks (before/after write, delete, etc.)
├── metadata.ex                     # Table metadata access
├── schema.ex                       # Mnesia schema management (create, destroy)
├── selection.ex                    # Selection result wrapper
└── table.ex                        # `deftable` macro — defines a table within a database
```
