defmodule YoSup do
  def start_link() do
    spawn_link(__MODULE__, :run, [])
  end

  def run(spec \\ init) do
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
        loop({supervise(spec), spec})
    end
  end

  def supervise({module, args}) do
    {:ok, pid} = apply(module, :start_link, args); pid
  end

  def child(pid) do
    send pid, {:child, self}
    receive do pid -> pid end
  end

  # YoSup Callbacks

  def init do
    {YoTP.OTP, []}
  end
end
