defmodule StepTwo do
  def start(from) do
    spawn(fn ->
      send from, :hey
    end)
  end
end
