
# Spawn a process
IO.puts "Process: #{inspect self}"
spawn(fn ->
  IO.puts "Process: #{inspect self}"
end)


# Send and recieve message
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
