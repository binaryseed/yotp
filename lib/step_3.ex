defmodule StepThree do
  require Logger

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
