defmodule Todo.Server do
  use GenServer

  def start(list_name) do
    GenServer.start(__MODULE__, list_name)
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

  @impl GenServer
  def init(list_name) do
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
end
