defmodule Todo.CacheTest do
  use ExUnit.Case

  test "server_process" do
    bob_pid = Todo.Cache.server_process("Bob")

    assert bob_pid != Todo.Cache.server_process("Alice")
    assert bob_pid == Todo.Cache.server_process("Bob")
  end

  test "to-do operations" do
    alice = Todo.Cache.server_process("Alice")
    Todo.Server.add_entry(alice, %{date: :tomorrow, title: "Dentist"})

    entries = Todo.Server.entries(alice, :tomorrow)
    assert [%{date: :tomorrow, title: "Dentist"}] = entries
  end
end
