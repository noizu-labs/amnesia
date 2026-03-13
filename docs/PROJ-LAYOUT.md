# Project Layout

```
amnesia/
├── lib/                            # Application source code
│   ├── amnesia/                    # Core library modules → [layout/lib-amnesia.md](layout/lib-amnesia.md)
│   │   ├── emulator/               #   Mnesia emulator (testing/mock layer)
│   │   ├── fragment/               #   Table fragmentation support
│   │   ├── table/                  #   Table operations (select, stream, match, etc.)
│   │   ├── access.ex               #   Transaction access helpers
│   │   ├── database.ex             #   Database definition macro
│   │   ├── hooks.ex                #   Lifecycle hook callbacks
│   │   ├── schema.ex               #   Mnesia schema management
│   │   └── table.ex                #   Table definition macro
│   ├── mix/                        # Mix tasks
│   │   ├── amnesia.create.ex       #   `mix amnesia.create` — create database tables
│   │   ├── amnesia.drop.ex         #   `mix amnesia.drop` — drop database tables
│   │   └── mix_amnesia.ex          #   Shared mix task helpers
│   └── amnesia.ex                  # Library entry point
├── test/                           # Test suites → [layout/test.md](layout/test.md)
│   ├── amnesia/                    #   Core module tests
│   ├── mix/                        #   Mix task tests
│   ├── support/                    #   Test support (database fixtures)
│   └── test_helper.exs             #   Test configuration
├── docs/                           # Documentation
│   ├── PROJ-ARCH.md                #   Architecture overview
│   ├── PROJ-ARCH.summary.md        #   Architecture quick reference
│   ├── PROJ-LAYOUT.md              #   This file
│   ├── PROJ-LAYOUT.summary.md      #   Layout quick reference
│   ├── arch/                       #   Detailed architecture docs
│   │   ├── emulator.md             #     Emulator design
│   │   ├── macro-dsl.md            #     defdatabase/deftable code generation
│   │   └── transactions.md         #     Transaction model and contexts
│   └── layout/                     #   Detailed directory breakdowns
│       ├── lib-amnesia.md          #     lib/amnesia/ breakdown
│       └── test.md                 #     test/ breakdown
├── .tool-versions                  # asdf — Erlang 28.4, Elixir 1.19.5
├── mix.exs                         # Project config, dependencies
├── mix.lock                        # Dependency lock file
└── README.md                       # Project overview
```

## Key Files Requiring Setup

| File | Action |
|------|--------|
| `.tool-versions` | Install runtimes via `asdf install` |
