seed = %{
  1 => %{id: 1, date: ~D[2024-05-25], title: "asdfasf"},
  2 => %{id: 2, date: ~D[2024-05-26], title: "asdfasfd2"}
}

defmodule TodoList do
  defstruct next_id: 1, entries: %{}

  def new(tasks \\ []) do
    Enum.reduce(tasks, %TodoList{}, &add_todo(&2, &1))
  end

  def entries(todo_list, date) do
    todo_list.entries
    |> Map.values()
    |> Enum.filter(&(&1.date == date))
  end

  def add_todo(todo_list, entry) do
    new_entry = Map.put(entry, :id, todo_list.next_id)

    new_entries =
      todo_list.entries
      |> Map.put(todo_list.next_id, new_entry)

    %TodoList{
      todo_list
      | entries: new_entries,
        next_id: todo_list.next_id + 1
    }
  end

  def update_todo(todo_list, id, updater_fn) do
    case Map.fetch(todo_list.entries, id) do
      :error ->
        todo_list

      {:ok, old_entry} ->
        new_entry = updater_fn.(old_entry)
        new_entries = Map.put(todo_list.entries, id, new_entry)
        %TodoList{todo_list | entries: new_entries}
    end
  end

  def delete_todo(todo_list, id) do
    new_entries =
      todo_list.entries
      |> Map.delete(id)

    %{todo_list | entries: new_entries}
  end
end

defmodule TodoList.CsvReader do
  def import_csv() do
    File.stream!("todos.csv", :line)
    |> Stream.map(&String.split(&1, ","))
    |> Stream.map(fn [date, title] -> %{date: Date.from_iso8601!(date), title: title} end)
    |> Enum.to_list()
    |> TodoList.new()
  end
end
