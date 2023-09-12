#            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#                    Version 2, December 2004
#
#            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#   TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION
#
#  0. You just DO WHAT THE FUCK YOU WANT TO.

defmodule Amnesia.Emulator.Records do
  require Record
  Record.defrecord(:emulator_session, [emulator: nil, table: nil, scenario: nil, slice: nil, settings: nil, table_settings: nil])
end
