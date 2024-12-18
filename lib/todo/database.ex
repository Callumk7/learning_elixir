defmodule Todo.Database do
  use GenServer

  @db_folder "./persist"
  @num_workers 3

  def start do
    GenServer.start(__MODULE__, nil, name: __MODULE__)
  end

  def store(key, data) do
    GenServer.cast(__MODULE__, {:store, key, data})
  end

  def get(key) do
    GenServer.call(__MODULE__, {:get, key})
  end

  def choose_worker(key, workers) do
    index = :erlang.phash2(key, @num_workers)
    Map.get(workers, index)
  end

  def init(_) do
    workers =
      for i <- 0..(@num_workers - 1), into: %{} do
        {:ok, pid} = Todo.DatabaseWorker.start(@db_folder)
        {i, pid}
      end

    File.mkdir_p(@db_folder)
    {:ok, workers}
  end

  def handle_cast({:store, key, data}, workers) do
    pid = choose_worker(key, workers)
    Todo.DatabaseWorker.store(pid, key, data)
    {:noreply, workers}
  end

  def handle_call({:get, key}, _from, workers) do
    pid = choose_worker(key, workers)
    data = Todo.DatabaseWorker.get(pid, key)
    {:reply, data, workers}
  end
end

# Worker threads. We will use three of these to handle our db connections
defmodule Todo.DatabaseWorker do
  use GenServer

  def start(db_folder) do
    GenServer.start(__MODULE__, db_folder)
  end

  def store(pid, key, data) do
    GenServer.cast(pid, {:store, key, data})
  end

  def get(pid, key) do
    GenServer.call(pid, {:get, key})
  end

  def init(db_folder) do
    File.mkdir_p(db_folder)
    {:ok, db_folder}
  end

  def handle_cast({:store, key, data}, db_folder) do
    key |> file_name(db_folder) |> File.write!(:erlang.term_to_binary(data))
    {:noreply, db_folder}
  end

  def handle_call({:get, key}, _from, db_folder) do
    data =
      case File.read(file_name(key, db_folder)) do
        {:ok, binary} -> :erlang.binary_to_term(binary)
        _ -> nil
      end

    {:reply, data, db_folder}
  end

  defp file_name(key, db_folder) do
    Path.join(db_folder, to_string(key))
  end
end
