
#
# Elixir/OTP
#  = Erlang's goal: Fault Tolerance
#    * Isolated, Lightweight Processes
#    * Asynchronous Message Passing
#    * Pre-emptive Scheduling
#
#  = Primitives
#    * spawn
#    * spawn_link
#    * send
#    * receive
#
#  = Resources
#    * http://ferd.ca/the-zen-of-erlang.html
#    * http://ftp.nsysu.edu.tw/FreeBSD/ports/distfiles/erlang/armstrong_thesis_2003.pdf
#

defmodule OffsiteTest do
  use ExUnit.Case

  test "Step 1 - Spawn a process" do

    IO.puts "Root: #{inspect self}"
    pid = spawn(fn ->
      IO.puts "Spawned: #{inspect self}"
    end)

    :timer.sleep(10)
    refute Process.alive?(pid)

  end

  test "Step 2 - Send a message to self" do

    send self, :hello
    receive do
      :hello -> IO.puts "Hello world"
    end

  end

  test "Step 3 - Recieve a message in another process" do

    pid = spawn(fn ->
      receive do
        msg -> IO.puts "Got #{msg}!"
      end
    end)
    send pid, :foobar

  end

  test "Step 4 - Send and Recieve a message back" do

    pid = spawn(fn ->
      receive do
        {:foo, from} -> send from, :bar
      end
    end)
    send pid, {:foo, self}
    receive do
      :bar -> IO.puts "FooBar"
    end

  end

  test "Step 5 - Start a process via MFA" do

   spawn(Step.Five, :func, [{:argu, :ments}])

  end

  test "Step 6 - Start a receive loop in a process" do

    pid = Step.Six.start

    send pid, {self, :ping}
    receive do
      :pong -> IO.puts "Pong"
    end

    send pid, {self, :foo}
    receive do
      :bar -> IO.puts "Bar"
    end

    assert Process.alive?(pid)
  end

  # Switch directions

  test "Step 7 - Link a process" do

    pid = spawn(fn ->
      spawn_link(fn ->
        Not.a_function
      end)
    end)

    :timer.sleep(10)
    refute Process.alive?(pid)
  end

  test "Step 8 - Trap exits" do

    pid = spawn(fn ->
      Process.flag :trap_exit, true
      spawn_link(fn ->
        AlsoNot.a_function
      end)
      receive do
        {:EXIT, _pid, _reason}=msg ->
          IO.puts "Caught #{inspect msg}"
      end
      :timer.sleep(100)
    end)

    :timer.sleep(10)
    assert Process.alive?(pid)
  end

  test "Step 9 - specify a child" do

    spec = {Offsite.Actor, []}
    pid = Step.Nine.start(spec)

    child = Step.Nine.child(pid)

    assert Process.alive?(pid)
    assert Process.alive?(child)

    assert GenServer.call(child, :ping) == :pong
  end

  test "Step 10 - Offsite.Supervisor - restart child when it dies" do

    spec = {Offsite.Actor, []}
    pid = Offsite.Supervisor.start_link(spec)

    first_pid = Offsite.Supervisor.child(pid)
    Process.exit(first_pid, :blow)
    refute Process.alive? first_pid

    second_pid = Offsite.Supervisor.child(pid)
    assert Process.alive? second_pid

    refute first_pid == second_pid
  end

end
