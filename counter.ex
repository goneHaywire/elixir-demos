defmodule Counter do

  # start interface function
  def start(count \\ 0) do
    spawn(fn -> loop(count) end)
  end

  # actual handling
  defp loop(count) do
    new_count = receive do
      {:inc, amount} -> count + amount
      {:dec, amount} -> count - amount
      {:set, amount} -> amount
      {:get, sender} -> 
        send(sender, {:count, count})
        count
    end

    loop(new_count)
  end

  # INTERFACE FUNCTIONS (helpers)

  # def inc(counter, amount \\ 1), do: send(counter, {:inc, amount})
    
  def dec(counter, amount \\ 1), do: send(counter, {:dec, amount})

  def set(counter, amount \\ 0), do: send(counter, {:set, amount})

  # it would be better to split this in 2 functions:
  # one that sends a message to the other process to get the counter value
  # and another that simply reads the counter response messags from the other process
  # currently, this is not that good because you need the PID even for reading the message which is not required theoretically
  # so by splitting you only need the PID for sending the message, and then the value can be read at any later time
  def get(counter) do
    send(counter, {:get, self()})
    receive do
      {:count, count} -> 
        IO.inspect("The count is: #{count}")
        count
    after 
      1000 -> {:error, :timeout}
    end
  end
end
