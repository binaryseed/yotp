defmodule StepThree do
  require Logger

  def start() do
    spawn(__MODULE__, :loop, [])
  end

  def loop() do
    receive do
      :ping -> Logger.debug("Pong!")
      :foo  -> Logger.debug("Bar")
    end
    loop()
  end
end
