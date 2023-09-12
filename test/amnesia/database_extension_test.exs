Code.require_file "../test_helper.exs", __DIR__





use Amnesia

defmodule ExtensionTest do


  def __before_database__(env) do
    s = Module.get_attribute(env.module, :deferred_tables)
    if is_list(s) do
      Enum.map(s, & Module.put_attribute(env.module, :tables, &1))
    end
  end

  defmacro extend_defdatabase do
    quote do
      Module.register_attribute(__MODULE__, :deferred_tables,  accumulate: true)
      @before_compile {unquote(__MODULE__), :__before_database__}
    end
  end

  defmacro __before_compile__(_) do

  end


  defmacro __using__(_ \\ nil) do
    quote do


      #--------------------
      # test
      #--------------------
      def read!(key) do
        :extended
      end
      def alternative_read!(key) do
        :hello
      end

    end
  end


  #
  #  defmacro __using__(opts \\ nil) do
  #    quote do
  #      def read!(key) do
  #        :extended
  #      end
  #      def alternative_read!(key) do
  #        :hello
  #      end
  #    end
  #  end
end


defdatabase Test2.Database do
  deftable User

  deftable ExtendedTable, [:identifier, :content], type: :set, extensions: :enabled do
    @type t :: %__MODULE__{
                 identifier: any,
                 content: any
               }
    use ExtensionTest
  end

end

defmodule DatabaseExtensionTest do
  use ExUnit.Case
  use Test2.Database

  test "user should be able to extend schema definitions to inject additional hooks and callbacks" do
    assert Test2.Database.ExtendedTable.read!(:apple) == :extended
    assert Test2.Database.ExtendedTable.alternative_read!(:apple) == :hello
    #assert Test2.Database.ExtendedTable.LocalCopy.options() == [type: :set, extensions: :enabled]
  end

  setup_all do
    Amnesia.Test.start

    on_exit fn ->
      Amnesia.Test.stop
    end
  end

  setup do
    Test.Database.create!

    on_exit fn ->
      Test.Database.destroy
    end
  end
end
