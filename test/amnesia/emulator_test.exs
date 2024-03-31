defmodule MockDB do
  use Amnesia.Emulator
  mockdatabase Database,
               database: TestDB
    do

    mocktable DummyATable do
      default_scenario do
        [
          %@table{
            identifier: 1,
            value: :apple
          }
        ]
      end

      scenario :alpha do
        [
          %@table{
            identifier: 1,
            value: :abba
          }
        ]
      end
    end

    mocktable DummyBTable do
      default_scenario do
        [
          %@table{
            identifier: 1,
            value: :boop
          }
        ]
      end
    end
  end
end


defmodule Noizu.Emulator.AmnesiaTest do
  use ExUnit.Case, async: false
  require Logger
  @moduletag :emulator

  @mock_extension Code.ensure_compiled?(Mock)
  if @mock_extension do
    import Mock
    setup_all do
      Amnesia.Test.start
      TestDB.DummyATable.create!
      TestDB.DummyBTable.create!
      on_exit fn ->
        Amnesia.Test.stop
      end
    end

    @tag :wip
    test "Default Scenario" do
      MockDB.start()
      assert MockDB.Database.tables() == [TestDB.DummyBTable, TestDB.DummyATable]
      with_mocks([
        MockDB.Database.mock(),
        MockDB.Database.DummyATable.mock(),
        MockDB.Database.DummyBTable.mock(),
      ]) do
        assert TestDB.tables() == [TestDB.DummyBTable, TestDB.DummyATable]
        a = TestDB.DummyATable.read!(1)
        assert a.value == :apple
        b = TestDB.DummyBTable.read!(1)
        assert b.value == :boop
      end
    end

    @tag :wip
    test "Custom Scenario" do
      MockDB.start(:alpha)
      assert MockDB.Database.tables() == [TestDB.DummyBTable, TestDB.DummyATable]
      with_mocks([
        MockDB.Database.mock(),
        MockDB.Database.DummyATable.mock(),
        MockDB.Database.DummyBTable.mock(),
      ]) do
        assert TestDB.tables() == [TestDB.DummyBTable, TestDB.DummyATable]
        a = TestDB.DummyATable.read!(1)
        assert a.value == :abba
        b = TestDB.DummyBTable.read!(1)
        assert b.value == :boop
      end
    end

    @tag :wip
    test "Crud" do
      MockDB.start()
      assert MockDB.Database.tables() == [TestDB.DummyBTable, TestDB.DummyATable]
      with_mocks([
        MockDB.Database.mock(),
        MockDB.Database.DummyATable.mock(),
        MockDB.Database.DummyBTable.mock(),
      ]) do
        TestDB.DummyATable.write!(%TestDB.DummyATable{identifier: 1, value: :bop})
        b = TestDB.DummyBTable.read!(1)
        TestDB.DummyBTable.delete!(b)
        a = TestDB.DummyATable.read!(1)
        b = TestDB.DummyBTable.read!(1)
        assert a.value == :bop
        assert b == nil
      end
    end

    @tag :wip
    test "Keys" do
      MockDB.start()
      assert MockDB.Database.tables() == [TestDB.DummyBTable, TestDB.DummyATable]
      with_mocks([
        MockDB.Database.mock(),
        MockDB.Database.DummyATable.mock(),
        MockDB.Database.DummyBTable.mock(),
      ]) do
        sut = TestDB.DummyATable.keys!()
        assert sut == [1]
      end
    end

    @tag :wip
    test "Events" do
      MockDB.start()
      assert MockDB.Database.tables() == [TestDB.DummyBTable, TestDB.DummyATable]
      with_mocks([
        MockDB.Database.mock(),
        MockDB.Database.DummyATable.mock(),
        MockDB.Database.DummyBTable.mock(),
      ]) do
        TestDB.DummyATable.write!(%TestDB.DummyATable{identifier: 1, value: :bop})
        b = TestDB.DummyBTable.read!(1)
        TestDB.DummyBTable.delete!(b)
        TestDB.DummyATable.read!(1)
        TestDB.DummyBTable.read!(1)
        TestDB.DummyBTable.keys!()
        events = MockDB.__history__()
        assert events == [
                 {1, {:write!, {TestDB.DummyATable, 1}}},
                 {2, {:read!, {TestDB.DummyBTable, 1}}},
                 {3, {:delete!, {TestDB.DummyBTable, 1}}},
                 {4, {:read!, {TestDB.DummyATable, 1}}},
                 {5, {:read!, {TestDB.DummyBTable, 1}}},
                 {6, {:keys!, {TestDB.DummyBTable}}},
               ]

        events = MockDB.__table_history__(TestDB.DummyATable)
        assert events == [{1, {:write!, 1}}, {4, {:read!, 1}}]

        events = MockDB.__record_history__(TestDB.DummyATable, 1)
        assert [{1, {:write!, _}}, {4, :read!}] = events

        record = MockDB.__record__(TestDB.DummyATable, 1)
        assert [{1, {:write!, _}}, {4, :read!}] = record.history
      end
    end

  end
end
