defmodule TodosServer do
  # will handle state init
  # will handle starting the server
  # will handle call messages
  # will handle cast messages
  # will have the interface functions
  def start(callback_module) do
  end
end

defmodule ServerProcess do
  # will have the loop function
  # will have cast function
  # will have call function
  # will have start function
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
