defmodule Todo.Server do
  use GenServer
  
  @impl GenServer
  def init(todos) do
    {:ok, Todo.List.new(todos)}
  end

  @impl GenServer
  def handle_call({:entries, date}, _, state) do
    {:reply, Todo.List.entries(state, date), state} 
  end

  @impl GenServer
  def handle_cast({:add_todo, entry}, state) do
    {:noreply, Todo.List.add_todo(state, entry)}
  end

  @impl GenServer
  def handle_cast({:update_todo, id, updater_fn}, state) do
    {:noreply, Todo.List.update_todo(state, id, updater_fn)}
  end

  @impl GenServer
  def handle_cast({:remove_todo, id}, state) do
    {:noreply, Todo.List.delete_todo(state, id)}
  end

  # interface functions
  def start(todos \\ []) do
    GenServer.start(__MODULE__, todos)
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
end
