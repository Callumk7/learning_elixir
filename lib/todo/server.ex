defmodule Todo.Server do
  use GenServer, restart: :temporary

  def start_link(list_name) do
    GenServer.start_link(__MODULE__, list_name, name: via_tuple(list_name))
  end

  def add_entry(todo_list, entry) do
    GenServer.cast(todo_list, {:add_entry, entry})
  end

  def update_entry(todo_list, id, updater_fn) do
    GenServer.cast(todo_list, {:update_entry, id, updater_fn})
  end

  def entries(todo_list, date) do
    GenServer.call(todo_list, {:entries, date})
  end

  # Callbacks

  @impl GenServer
  def init(list_name) do
    IO.puts("Starting the todo server")
    {:ok, {list_name, nil}, {:continue, :init}}
  end

  @impl GenServer
  def handle_continue(:init, {list_name, nil}) do
    todo_list = Todo.Database.get(list_name) || Todo.List.new()
    {:noreply, {list_name, todo_list}}
  end

  @impl GenServer
  def handle_cast({:add_entry, entry}, {list_name, todo_list}) do
    new_list = Todo.List.add_entry(todo_list, entry)
    Todo.Database.store(list_name, new_list)
    {:noreply, {list_name, new_list}}
  end

  @impl GenServer
  def handle_cast({:update_entry, id, updater_fn}, {list_name, todo_list}) do
    new_list = Todo.List.update_entry(todo_list, id, updater_fn)
    Todo.Database.store(list_name, new_list)
    {:noreply, {list_name, new_list}}
  end

  @impl GenServer
  def handle_call({:entries, date}, _from, {list_name, todo_list}) do
    {:reply, Todo.List.entries(todo_list, date), {list_name, todo_list}}
  end

  # Private helpers

  defp via_tuple(list_name) do
    Todo.ProcessRegistry.via_tuple({__MODULE__, list_name})
  end
end

# # Agent version of the Server module
# defmodule Todo.Server do
#   use Agent, restart: :temporary
#
#   def start_link(list_name) do
#     Agent.start_link(
#       fn ->
#         IO.puts("Starting todo server for #{list_name}")
#         {list_name, Todo.Database.get(list_name) || Todo.List.new()}
#       end,
#       name: via_tuple(list_name)
#     )
#   end
#
#   def add_entry(todo_list, entry) do
#     Agent.cast(todo_list, fn {list_name, todo_list} ->
#       new_list = Todo.List.add_entry(todo_list, entry)
#       Todo.Database.store(list_name, new_list)
#       {list_name, new_list}
#     end)
#   end
#
#   def update_entry(todo_list, id, updater_fn) do
#     Agent.cast(todo_list, fn {list_name, todo_list} ->
#       new_list = Todo.List.update_entry(todo_list, id, updater_fn)
#       Todo.Database.store(list_name, new_list)
#       {list_name, new_list}
#     end)
#   end
#
#   def entries(todo_list, date) do
#     Agent.get(todo_list, fn {_name, todo_list} -> Todo.List.entries(todo_list, date) end)
#   end
#
#   # Private helpers
#
#   defp via_tuple(list_name) do
#     Todo.ProcessRegistry.via_tuple({__MODULE__, list_name})
#   end
# end
#
