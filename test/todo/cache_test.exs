defmodule Todo.CacheTest do
  use ExUnit.Case

  test "server_process" do
    {:ok, cache} = Todo.Cache.start()
    bob_pid = Todo.Cache.server_process(cache, "Bob")

    assert bob_pid != Todo.Cache.server_process(cache, "Alice")
    assert bob_pid == Todo.Cache.server_process(cache, "Bob")
  end

  test "to-do operations" do
    {:ok, cache} = Todo.Cache.start()

    alice = Todo.Cache.server_process(cache, "Alice")
    Todo.Server.add_entry(alice, %{date: :tomorrow, title: "Dentist"})

    entries = Todo.Server.entries(alice, :tomorrow)
    assert [%{date: :tomorrow, title: "Dentist"}] = entries
  end
end
