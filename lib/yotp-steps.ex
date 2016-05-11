




defmodule YoTP.Five do
  def func(args) do
    IO.puts "#{inspect self}: #{inspect args}"
  end
end





defmodule YoTP.Six do
  def start() do
    spawn(__MODULE__, :loop, [])
  end

  def loop() do
    receive do
      {from, :ping} ->
        send from, :pong
      {from, :foo} ->
        send from, :bar
    end
    loop()
  end
end





defmodule YoTP.Seven do
  def start() do
    spawn(__MODULE__, :loop, [])
  end

  def loop() do
    receive do
      {from, :ping} ->
        send from, :pong
      {from, :foo} ->
        send from, :bar
    end
    loop()
  end

  def call(pid, query) do
    send pid, {self(), query}
    receive do
      answer -> answer
    end
  end
end





defmodule YoTP.Eight do
  def start() do
    spawn(__MODULE__, :loop, [0])
  end

  def loop(state) do
    new_state = receive do
      {from, :ping} ->
        new_state = state + 1
        send from, {:pong, new_state}
        new_state
      {from, :PING} ->
        new_state = state + 10
        send from, {:PONG, new_state}
        new_state
      {from, {:set, n}} ->
        new_state = n
        send from, {:PONG, new_state}
        new_state
    end
    loop(new_state)
  end

  def call(pid, query) do
    send pid, {self(), query}
    receive do
      answer -> answer
    end
  end
end
