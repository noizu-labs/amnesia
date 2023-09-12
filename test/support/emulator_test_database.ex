
use Amnesia
defdatabase TestDB do
  deftable DummyATable, [:identifier, :value], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: any,
                 value: any
               }
  end # end deftable

  deftable DummyBTable, [:identifier, :value], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: any,
                 value: any
               }
  end # end deftable

end
