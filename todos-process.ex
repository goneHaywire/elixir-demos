defmodule TodosProcess do
  def start() do
    spawn(fn -> loop(TodoList.new()) end)
  end

  defp loop(state) do
    new_state =
      receive do
        {:entries, caller, date} ->
          send(caller, {:entries, TodoList.entries(state, date)})
          state

        {:add_todo, todo} ->
          state |> TodoList.add_todo(todo)

        {:update_todo, id, updater_fn} ->
          state |> TodoList.update_todo(id, updater_fn)

        {:remove_todo, id} ->
          state |> TodoList.delete_todo(id)

        unknown ->
          IO.puts("unknown message: #{unknown}")
          state
      end

    loop(new_state)
  end

  def add_todo(pid, todo) do
    send(pid, {:add_todo, todo})
    pid
  end

  def entries(pid, date) do
    send(pid, {:entries, self(), date})

    receive do
      {:entries, entries} -> entries
    after
      2000 -> IO.puts("no entries received")
    end
  end
end

defmodule TodoList do
  defstruct next_id: 1, entries: %{}

  def new() do
    %TodoList{}
  end

  def import_task_list(list) do
    Enum.reduce(list, TodoList.new(), &TodoList.add_todo(&2, &1))
  end

  def entries(todo_list, date) do
    todo_list.entries
    |> Map.values()
    |> Enum.filter(fn entry -> entry.date == date end)
  end

  def add_todo(todo_list, entry) do
    new_entry = Map.put(entry, :id, todo_list.next_id)

    new_entries =
      todo_list.entries
      |> Map.put(todo_list.next_id, new_entry)

    %TodoList{
      todo_list
      | entries: new_entries,
        next_id: todo_list.next_id + 1
    }
  end

  def update_todo(todo_list, id, updater_fn) do
    case Map.fetch(todo_list.entries, id) do
      :error ->
        todo_list

      {:ok, old_entry} ->
        new_entry = updater_fn.(old_entry)
        new_entries = Map.put(todo_list.entries, id, new_entry)
        %TodoList{todo_list | entries: new_entries}
    end
  end

  def delete_todo(todo_list, id) do
    new_entries =
      todo_list.entries
      |> Map.delete(id)

    %{todo_list | entries: new_entries}
  end
end
