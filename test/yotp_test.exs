#
# Elixir/OTP
#  = Erlang's goal: Fault Tolerance
#    * Isolated, Lightweight Processes
#    * Asynchronous Message Passing
#    * Pre-emptive Scheduling
#
#  = Primitives
#    * spawn
#    * send
#    * receive
#
#  = Resources
#    * http://ferd.ca/the-zen-of-erlang.html
#    * http://ftp.nsysu.edu.tw/FreeBSD/ports/distfiles/erlang/armstrong_thesis_2003.pdf
#

defmodule YoTPTest do
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

   spawn(YoTP.Five, :func, [{:argu, :ments}])

  end

  test "Step 6 - Start a receive loop in a process" do

    pid = YoTP.Six.start

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

  test "Step 7 - Provide a client interface" do

    pid = YoTP.Seven.start

    assert YoTP.Seven.call(pid, :ping) == :pong
    assert YoTP.Seven.call(pid, :foo) == :bar

  end

  test "Step 8 - Add state to the process" do

    pid = YoTP.Eight.start

    assert YoTP.Eight.call(pid, :ping) == {:pong, 1}
    assert YoTP.Eight.call(pid, :PING) == {:PONG, 11}
    assert YoTP.Eight.call(pid, :ping) == {:pong, 12}

  end

  test "Step 9 - YoTP - Add callbacks to generalize" do

    pid = YoTP.start

    assert YoTP.call(pid, :ping) == :pong
    assert YoTP.call(pid, :ping) == :pong
    assert YoTP.call(pid, :ping) == :pong

    assert YoTP.call(pid, :count) == 3

  end

  test "OTP - Use OTP GenServer" do

    {:ok, pid} = YoTP.OTP.start

    assert GenServer.call(pid, :ping) == :pong
    assert GenServer.call(pid, :ping) == :pong
    assert GenServer.call(pid, :ping) == :pong

    assert GenServer.call(pid, :count) == 3

  end
end
