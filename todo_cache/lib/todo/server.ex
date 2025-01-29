defmodule Todo.Server do
  use Agent, restart: :temporary

  def start_link(list_name) do
    Agent.start_link(
      fn -> 
        IO.puts("Starting to-do server for #{list_name}")
        {list_name, Todo.Database.get(list_name) || Todo.List.new()}
      end,
      name: via_tuple(list_name)
    )
  end

  def entries(pid, date) do
    Agent.get(
      pid,
      fn {_name, todo_list} -> Todo.List.entries(todo_list, date) end
    )
  end

  def add_todo(pid, entry) do
    Agent.cast(
      pid,
      fn {name, todo_list} ->
        new_list = Todo.List.add_todo(todo_list, entry)
        Todo.Database.store(name, new_list)
        {name, new_list}
      end
    )
  end

  def update_todo(pid, id, updater_fn) do
    Agent.cast(
      pid,
      fn {name, todo_list} ->
        new_list = Todo.List.update_todo(todo_list, id, updater_fn)
        Todo.Database.store(name, new_list)
        {name, new_list}
      end
    )
  end

  def remove_todo(pid, id) do
    Agent.cast(
      pid,
      fn {name, todo_list} ->
        new_list = Todo.List.delete_todo(todo_list, id)
        Todo.Database.store(name, new_list)
        {name, new_list}
      end
    )
  end

  defp via_tuple(list_name) do
    Todo.ProcessRegistry.via_tuple({__MODULE__, list_name})
  end
end
