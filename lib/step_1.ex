defmodule StepOne do
  require Logger
  def start() do
    spawn(fn ->
      Logger.debug "Hello, world"
    end)
  end
end
