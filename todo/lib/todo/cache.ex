defmodule Todo.Cache do
  use GenServer

  def init(_) do
   {:ok, %{} }
  end

  def start do
    GenServer.start(__MODULE__, nil)
  end

  def server_process(cache_pid, todo_list_name) do
    GenServer.call(cache_pid, {:server_process, todo_list_name})
  end

  def handle_call({:server_process, name}, _caller, todo_cache) do
    # TODO: implement both get and put in this endpoint
    # search for name in map
    # return it if found
    # if not found, create it, put it in map, update map and return the pid
    case Map.fetch(todo_cache, name) do
      {:ok, todo_pid} -> {:reply, todo_pid, todo_cache}

      :error ->
        {:ok, todo_pid} = Todo.Server.start()
        {:reply, todo_pid, Map.put(todo_cache, name, todo_pid)}
    end
  end

end
