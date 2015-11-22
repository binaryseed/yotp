defmodule YoTP do
  def start() do
    spawn(__MODULE__, :run, [init])
  end

  def run(state) do
    loop(state)
  end

  def loop(state) do
    receive do
      {from, ref, query} ->
        {answer, new_state} = handle(query, state)
        send from, {ref, answer}
        loop(new_state)
    end
  end

  def call(pid, query, ref \\ make_ref) do
    send pid, {self(), ref, query}
    receive do
      {^ref, answer} -> answer
    end
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
