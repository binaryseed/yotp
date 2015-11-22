defmodule YoTP do
  def start() do
    spawn(__MODULE__, :run, [])
  end

  def run(state \\ init) do
    state |> loop
  end

  def loop(state) do
    receive do
      {from, ref, query} ->
        {reply, new_state} = handle(query, state)
        send from, {ref, reply}
        loop(new_state)
    end
  end

  def call(pid, query, ref \\ make_ref) do
    send pid, {self(), ref, query}
    receive do {^ref, reply} -> reply end
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
