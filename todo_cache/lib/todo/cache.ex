defmodule Todo.Cache do
  use GenServer

  @impl GenServer
  def init(_), do: {:ok, %{}}

  @impl GenServer
  def handle_call({:get_list, list_name}, _, cache) do
    {new_cache, todo_list_pid } = case Map.fetch(cache, list_name) do
      {:ok, todo_list_pid} -> {cache, todo_list_pid}
      :error -> 
        {:ok, todo_server} = Todo.Server.start()
        {Map.put(cache, list_name, todo_server), todo_server}
    end
    # IO.inspect(new_cache)
    # IO.inspect( todo_list_pid)

    {:reply, todo_list_pid, new_cache}
  end

  def start, do: GenServer.start(__MODULE__, nil)

  def server_process(cache_pid, todo_list_name) do
    GenServer.call(cache_pid, {:get_list, todo_list_name})
    #
    # receive do
    #   todo_list_pid -> 
    #     IO.inspect("The PID is #{todo_list_pid}")
    #     todo_list_pid
    #   after 1000 -> IO.puts(:stderr, "Error: No Todo List found")
    # end
  end
end