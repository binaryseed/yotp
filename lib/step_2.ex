defmodule StepTwo do
  def start(from) do
    spawn(fn ->
      send from, :hey
    end)
  end
end

defmodule StepTwoPointFive do
  require Logger
  def start(from) do
    spawn(fn ->
      receive do
        msg -> Logger.debug(msg)
      end
    end)
  end
end
