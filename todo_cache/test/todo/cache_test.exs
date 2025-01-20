defmodule Todo.CasheTest do
  use ExUnit.Case

  test "server_process" do
    {:ok, cache} = Todo.Cache.start()
    todo1_pid = Todo.Cache.server_process(cache, :todo1)

    assert todo1_pid != Todo.Cache.server_process(cache, :todo2)
    assert todo1_pid == Todo.Cache.server_process(cache, :todo1)
  end
  
  test "to-do operations" do
    {:ok, cache} = Todo.Cache.start()
    todo1 = Todo.Cache.server_process(cache, :todo1)
    Todo.Server.add_todo(todo1, %{date: ~D[2020-12-20], title: "todo1 at todo1"})

    entries = Todo.Server.entries(todo1, ~D[2020-12-20])
    assert [%{date: ~D[2020-12-20], title: "todo1 at todo1"}] = entries
  end
end
