defmodule Todo.Server do
  use GenServer, restart: :temporary

  # interface functions
  def start_link(list_name) do
    GenServer.start_link(__MODULE__, list_name, name: via_tuple(list_name))
  end

  def entries(pid, date) do
    GenServer.call(pid, {:entries, date})
  end

  def add_todo(pid, entry) do
    GenServer.cast(pid, {:add_todo, entry})
  end

  def update_todo(pid, id, updater_fn) do
    GenServer.cast(pid, {:update_todo, id, updater_fn})
  end

  def remove_todo(pid, id) do
    GenServer.cast(pid, {:remove_todo, id})
  end

  defp via_tuple(list_name) do
    Todo.ProcessRegistry.via_tuple({__MODULE__, list_name})
  end
  
  @impl GenServer
  def init(list_name) do
    {:ok, {list_name, nil}, {:continue, :init}}
  end

  @impl GenServer
  def handle_continue(:init, {list_name, nil}) do
    list = Todo.Database.get(list_name) || Todo.List.new()
    IO.inspect(list_name)
    {:noreply, {list_name, list}}
  end

  @impl GenServer
  def handle_call({:entries, date}, _, {list_name, todos}) do

    {:reply, Todo.List.entries(todos, date), {list_name, todos}} 
  end

  @impl GenServer
  def handle_cast({:add_todo, entry}, {list_name, todos}) do
    new_todos = Todo.List.add_todo(todos, entry)
    Todo.Database.store(list_name, new_todos)
    {:noreply, {list_name, new_todos}}
  end

  @impl GenServer
  def handle_cast({:update_todo, id, updater_fn}, {list_name, todos}) do
    new_todos = Todo.List.update_todo(todos, id, updater_fn)
    Todo.Database.store(list_name, new_todos)
    {:noreply, {list_name, new_todos}}
  end

  @impl GenServer
  def handle_cast({:remove_todo, id}, {list_name, todos}) do
    new_todos = Todo.List.delete_todo(todos, id)
    Todo.Database.store(list_name, new_todos)
    {:noreply, {list_name, new_todos}}
  end
end
