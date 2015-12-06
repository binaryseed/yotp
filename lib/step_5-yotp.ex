defmodule YoTP do
  # YoTP fake GenServer

  def start() do
    spawn(__MODULE__, :run, [])
  end

  def run() do
    init |> loop
  end

  def loop(state) do
    receive do
      {from, query} ->
        {reply, new_state} = handle(query, state)
        send from, reply
        loop(new_state)
    end
  end

  def call(pid, query) do
    send pid, {self(), query}
    receive do reply -> reply end
  end

  # YoTP Callbacks

  def init(), do: %{count: 0}

  def handle(:ping, state) do
    {:pong, %{state | count: state.count+1}}
  end

  def handle(:count, state) do
    {state.count, state}
  end
end
