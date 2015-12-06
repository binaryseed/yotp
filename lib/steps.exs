

# Spawn a process
IO.puts "Process: #{inspect self}"
spawn(fn ->
  IO.puts "Process: #{inspect self}"
end)


# Recieve message
send self, :hello
receive do
  :hello -> IO.puts "hello world"
end


# Recieve in another process
pid = spawn(fn ->
  receive do
    msg -> IO.puts "Got #{msg}!"
  end
end)
send pid, :foobar


# Send and Recieve a message
pid = spawn(fn ->
  receive do
    {:foo, from} -> send from, :bar
  end
end)
send pid, {:foo, self}
receive do
  :bar -> IO.puts "FooBar"
end

