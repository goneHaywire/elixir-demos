defmodule Todo.DatabaseWorker do
  use GenServer 

  def start_link({db_folder, id}) do
    GenServer.start_link(__MODULE__, db_folder, name: via_tuple(id))
  end

  def store(worker_id, key, data) do
    IO.inspect("Get Key: #{key} from worker_id: #{worker_id}")
    GenServer.cast(via_tuple(worker_id), {:store, key, data})
  end

  def get(worker_id, key) do
    IO.inspect("Get Key: #{key} from worker_id: #{worker_id}")
    GenServer.call(via_tuple(worker_id), {:get, key})
  end

  defp via_tuple(id) do
    Todo.ProcessRegistry.via_tuple({__MODULE__, id})
  end

  @impl GenServer
  def init(db_folder) do
    IO.puts("Database Worker Started")
    {:ok, db_folder}
  end

  @impl GenServer
  def handle_cast({:store, key, val}, db_folder) do
    key 
      |> file_name(db_folder)
      |> File.write!(:erlang.term_to_binary(val))
    
    {:noreply, db_folder}
  end

  @impl GenServer
  def handle_call({:get, key}, _, db_folder) do
    data = case File.read(file_name(key, db_folder)) do
      {:ok, contents} -> :erlang.binary_to_term(contents)
      _ -> nil
    end
    
    {:reply, data, db_folder}
  end

  defp file_name(key, db_folder) do
    Path.join(db_folder, to_string(key))
  end
end
