defmodule TodosProcess do
  def start() do
    spawn(fn -> loop(TodoList.new()) end)
  end

  defp loop(todos) do
    new_todos =
      receive do
        message -> process_message(todos, message)
      end

    loop(new_todos)
  end

  defp process_message(todos, {:entries, caller, date}) do
    send(caller, {:entries, TodoList.entries(todos, date)})
    todos
  end

  defp process_message(todos, {:add_todo, todo}) do
    todos |> TodoList.add_todo(todo)
  end

  defp process_message(todos, {:update_todo, id, updater_fn}) do
    todos |> TodoList.update_todo(id, updater_fn)
  end

  defp process_message(todos, {:remove_todo, id}) do
    todos |> TodoList.delete_todo(id)
  end

  defp process_message(todos, unknown) do
    IO.puts("unknown message: #{unknown}")
    todos
  end

  def add_todo(todo_server, todo) do
    send(todo_server, {:add_todo, todo})
    todo_server
  end

  def update_todo(todo_server, id, updater_fn) do
    send(todo_server, {:update_todo, id, updater_fn})
    todo_server
  end

  def remove_todo(todo_server, id) do
    send(todo_server, {:remove_todo, id})
    todo_server
  end

  def entries(todo_server, date) do
    send(todo_server, {:entries, self(), date})

    receive do
      {:entries, entries} -> entries
    after
      2000 -> 
        IO.puts("no entries received")
        nil
    end
  end
end

defmodule TodoList do
  defstruct next_id: 1, entries: %{}

  def new(tasks \\ []) do
    Enum.reduce(tasks, %TodoList{}, &add_todo(&2, &1))
  end

  def entries(todo_list, date) do
    todo_list.entries
    |> Map.values()
    |> Enum.filter(&(&1.date == date))
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
