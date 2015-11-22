defmodule YoSup do
  def start_link() do
    spawn_link(__MODULE__, :run, [init])
  end

  def run(spec) do
    Process.flag(:trap_exit, true)
    loop({supervise(spec), spec})
  end

  def loop({child, spec}) do
    receive do
      {:child, from} ->
        send from, child
        loop({child, spec})
      {:EXIT, ^child, _reason} ->
        loop({supervise(spec), spec})
    end
  end

  def supervise({module, fun, args}) do
    {:ok, pid} = apply(module, fun, args)
    pid
  end

  def child(pid) do
    send pid, {:child, self}
    receive do pid -> pid end
  end

  # YoSup Callbacks

  def init do
    {OTP, :start_link, []}
  end
end