defmodule Todo.List do
  defstruct next_id: 1, entries: %{}

  def new(entries \\ []) do
    Enum.reduce(entries, %Todo.List{}, &add_entry(&2, &1))
  end

  def add_entry(todo_list, entry) do
    entry = Map.put(entry, :id, todo_list.next_id)
    new_entries = Map.put(todo_list.entries, todo_list.next_id, entry)

    %Todo.List{todo_list | entries: new_entries, next_id: todo_list.next_id + 1}
  end

  def entries(todo_list, date) do
    todo_list.entries |> Map.values() |> Enum.filter(fn entry -> entry.date == date end)
  end

  def update_entry(todo_list, id, updater_fn) do
    case Map.fetch(todo_list.entries, id) do
      :error ->
        todo_list

      {:ok, entry} ->
        new_entry = updater_fn.(entry)
        new_entries = Map.put(todo_list.entries, new_entry.id, new_entry)
        %Todo.List{todo_list | entries: new_entries}
    end
  end

  def delete_entry(todo_list, id) do
    new_entries = Map.delete(todo_list.entries, id)
    %Todo.List{todo_list | entries: new_entries}
  end
end
