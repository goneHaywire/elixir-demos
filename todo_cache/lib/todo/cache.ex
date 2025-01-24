defmodule Todo.Cache do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def server_process(todo_list_name) do
    GenServer.call(__MODULE__, {:get_list, todo_list_name})
  end

  @impl GenServer
  def init(_) do
    IO.puts("Cache Server Starting")
    {:ok, %{}}
  end

  @impl GenServer
  def handle_call({:get_list, list_name}, _, cache) do
    {new_cache, todo_list_pid } = case Map.fetch(cache, list_name) do
      {:ok, todo_list_pid} -> {cache, todo_list_pid}
      :error -> 
        {:ok, todo_server} = Todo.Server.start_link(list_name)
        {Map.put(cache, list_name, todo_server), todo_server}
    end

    {:reply, todo_list_pid, new_cache}
  end
end
