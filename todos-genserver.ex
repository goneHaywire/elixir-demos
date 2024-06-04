defmodule TodoServer do
  use GenServer

  def start do
    GenServer.start(__MODULE__, nil)
  end

  def entries(pid, date) do
    GenServer.call(pid, {:entries, date})
  end

  def add_todo(pid, todo) do
    GenServer.cast(pid, {:add_todo, todo})
  end

  def update_todo(pid, id, updater_fn) do
    GenServer.cast(pid, {:update_todo, id, updater_fn})
  end

  def remove_todo(pid, id) do
    GenServer.cast(pid, {:remove_todo, id})
  end

  @impl true
  def init(_) do
    {:ok, TodoList.new()}
  end

  @impl true
  def handle_cast({:add_todo, todo}, state) do
    {:noreply, TodoList.add_todo(state, todo)}
  end

  @impl true
  def handle_cast({:update_todo, id, updater_fn}, state) do
    {:noreply, TodoList.update_todo(state, id, updater_fn)}
  end

  @impl true
  def handle_cast({:remove_todo, id}, state) do
    {:noreply, TodoList.delete_todo(state, id)}
  end

  @impl true
  def handle_call({:entries, date}, _, state) do
    {:reply, TodoList.entries(state, date), state}
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
