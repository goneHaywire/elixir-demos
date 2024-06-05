defmodule Todo.Server do
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
    {:ok, Todo.List.new()}
  end

  @impl true
  def handle_cast({:add_todo, todo}, state) do
    {:noreply, Todo.List.add_todo(state, todo)}
  end

  @impl true
  def handle_cast({:update_todo, id, updater_fn}, state) do
    {:noreply, Todo.List.update_todo(state, id, updater_fn)}
  end

  @impl true
  def handle_cast({:remove_todo, id}, state) do
    {:noreply, Todo.List.delete_todo(state, id)}
  end

  @impl true
  def handle_call({:entries, date}, _, state) do
    {:reply, Todo.List.entries(state, date), state}
  end
end
