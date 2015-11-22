defmodule StepFour do
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
