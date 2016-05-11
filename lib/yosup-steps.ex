

defmodule YoSup.Three do
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

