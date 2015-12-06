defmodule OTP do
  use GenServer

  def start,      do: GenServer.start(__MODULE__, :ok, [])
  def start_link, do: GenServer.start_link(__MODULE__, :ok, [])

  def init(:ok) do
    {:ok, %{count: 0}}
  end

  def handle_call(:ping, _from, state) do
    {:reply, :pong, %{state | count: state.count+1}}
  end

  def handle_call(:count, _from, state) do
    {:reply, state.count, state}
  end
end
