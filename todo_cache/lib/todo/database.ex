defmodule Todo.Database do
  use GenServer 
  @db_folder "./persist"

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def store(key, data) do
    worker = choose_worker(key)
    GenServer.cast(worker, {:store, key, data})
  end

  def get(key) do
    worker = choose_worker(key)
    GenServer.call(worker, {:get, key})
  end

  defp choose_worker(key) do
    GenServer.call(__MODULE__, {:choose_worker, key})
  end

  @impl GenServer
  def init(_) do
    IO.puts("Database Server Started")

    servers = 0..2
      |> Enum.map(&{ &1, Todo.DatabaseWorker.start(@db_folder)})
      |> Enum.map(fn {key, {_, pid}} -> { key, pid} end)
      |> Enum.into(%{})

    {:ok, servers}
  end

  @impl GenServer
  def handle_cast({:store, key, val}, state) do
    key 
      |> file_name()
      |> File.write!(:erlang.term_to_binary(val))
    
    {:noreply, state}
  end

  @impl GenServer
  def handle_call({:choose_worker, key}, _, servers) do
    {:reply, Map.get(servers, :erlang.phash2(key, 3)), servers}
  end

  @impl GenServer
  def handle_call({:get, key}, _, state) do
    data = case File.read(file_name(key)) do
      {:ok, contents} -> :erlang.binary_to_term(contents)
      _ -> nil
    end
    
    {:reply, data, state}
  end

  defp file_name(key) do
    Path.join(@db_folder, to_string(key))
  end
end
