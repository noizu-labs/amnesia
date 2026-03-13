# test/ — Test Suites

```
test/
├── amnesia/                        # Core module tests
│   ├── amnesia_test.exs            # Top-level Amnesia module tests
│   ├── database_test.exs           # Database definition and operations
│   ├── database_extension_test.exs # Database extension/inheritance
│   ├── emulator_test.exs           # Emulator functionality
│   ├── fragment_test.exs           # Table fragmentation
│   └── hooks_test.exs              # Lifecycle hooks
├── mix/                            # Mix task tests
│   ├── amnesia_create_test.exs     # `mix amnesia.create` task
│   ├── amnesia_drop_test.exs       # `mix amnesia.drop` task
│   └── mix_helper.exs              # Shared test helpers for mix tasks
├── support/                        # Test support modules
│   └── emulator_test_database.ex   # Test database definition for emulator tests
└── test_helper.exs                 # Test configuration and setup
```
