



defmodule Step.Five do
  def func(args) do
    IO.puts "#{inspect self}: #{inspect args}"
  end
end





defmodule Step.Six do
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




defmodule Step.Nine do
  def start(spec) do
    spawn(__MODULE__, :run, [spec])
  end

  def run({mod, args}) do
    {:ok, child} = apply(mod, :start_link, args)
    child |> loop
  end

  def loop(child) do
    receive do
      {:child, from} ->
        send from, child
        loop(child)
    end
  end

  def child(pid) do
    send pid, {:child, self}
    receive do child -> child end
  end
end











defmodule Offsite.Actor do
  use GenServer

  def start_link, do: GenServer.start_link(__MODULE__, :ok, [])

  def init(:ok) do
    {:ok, %{count: 0}}
  end

  def handle_call(:hello, _from, state) do
    IO.puts "Actor is alive #{inspect self}"
    {:reply, :hi, state}
  end

  def handle_call(:ping, _from, state) do
    {:reply, :pong, %{state | count: state.count+1}}
  end

  def handle_call(:count, _from, state) do
    {:reply, state.count, state}
  end
end

defmodule Offsite.Supervisor do
  def start_link(spec) do
    spawn_link(__MODULE__, :run, [spec])
  end

  def run(spec) do
    Process.flag(:trap_exit, true)
    child = supervise(spec)
    loop({child, spec})
  end

  def loop({child, spec}) do
    receive do
      {:child, from} ->
        send from, child
        loop({child, spec})
      {:EXIT, ^child, _reason} ->
        new_child = supervise(spec)
        loop({new_child, spec})
    end
  end

  def supervise({module, args}) do
    {:ok, pid} = apply(module, :start_link, args)
    pid
  end

  def child(pid) do
    send pid, {:child, self}
    receive do pid -> pid end
  end
end





