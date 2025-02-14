defmodule Todo.CasheTest do
  use ExUnit.Case

  test "server_process" do
    todo1_pid = Todo.Cache.server_process(:todo1)

    assert todo1_pid != Todo.Cache.server_process(:todo2)
    assert todo1_pid == Todo.Cache.server_process(:todo1)
  end

  test "to-do operations" do
    todo1 = Todo.Cache.server_process(:todo1)
    Todo.Server.add_todo(todo1, %{date: ~D[2020-12-20], title: "todo1 at todo1"})

    entries = Todo.Server.entries(todo1, ~D[2020-12-20])
    assert [%{date: ~D[2020-12-20], title: "todo1 at todo1"}] = entries
  end
end
