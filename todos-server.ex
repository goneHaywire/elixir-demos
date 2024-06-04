defmodule TodosServer do
  # will handle call messages
  # will handle cast messages
  # will have the interface functions

  def start do
    ServerProcess.start()
  end

  def init do
    TodoList.new()
  end

  def entries(pid, date) do
    ServerProcess.call(pid, {:entries, date})
  end

  def add_todo(pid, todo) do
    ServerProcess.cast(pid, {:add_todo, todo})
  end

  def remove_todo(pid, id) do
    ServerProcess.cast(pid, {:remove_todo, id})
  end

  def update_todo(pid, id, update_fn) do
    ServerProcess.call(pid, {:update_todo, id, update_fn})
  end
end

defmodule ServerProcess do
  def start(callback_module) do
    spawn(fn -> loop(callback_module, callback_module.init()) end)
  end

  def loop(callback_module, state) do
    new_state =
      receive do
        message -> callback_module.handle_message(message)
      end

    loop(callback_module, new_state)
  end

  def call(pid, message) do
    send(pid, self(), message)

    receive do
      {:response, message} -> message
    after
      5000 -> IO.puts("no response")
    end
  end

  def cast(pid, message) do
    send(pid, message)
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
