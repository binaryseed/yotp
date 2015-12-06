#
# * Concurrent Processes
# * Strong Isolation
# * Message Passing
# * Fail Fast
#

defmodule YoTPTest do
  use ExUnit.Case

  test "Step 1 - Spawn a process" do

    IO.puts "Root: #{inspect self}"
    pid = spawn(fn ->
      IO.puts "Spawned: #{inspect self}"
    end)

    :timer.sleep(1)
    refute Process.alive?(pid)
  end

  test "Step 1.5 - Send a message to self" do

    send self, :hello
    receive do
      :hello -> IO.puts "Hello world"
    end

  end

  test "Step 2 - Recieve a message in another process" do

    pid = spawn(fn ->
      receive do
        msg -> IO.puts "Got #{msg}!"
      end
    end)
    send pid, :foobar

  end

  test "Step 2.5 - Send and Recieve a message back" do

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

  test "Step 3 - Start a receive loop in a process" do

    pid = StepThree.start

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

  test "Step 4 - Provide a client interface" do

    pid = StepFour.start

    assert StepFour.call(pid, :ping) == :pong
    assert StepFour.call(pid, :foo) == :bar
  end

  test "Step 4.5 - Add state to the process" do

    pid = StepFourPointFive.start

    assert StepFourPointFive.call(pid, :ping) == {:pong, 1}
    assert StepFourPointFive.call(pid, :PING) == {:PONG, 11}
    assert StepFourPointFive.call(pid, :ping) == {:pong, 12}
  end

  test "Step 5 - YoTP - Add callbacks to generalize" do

    pid = YoTP.start

    assert YoTP.call(pid, :ping) == :pong
    assert YoTP.call(pid, :ping) == :pong
    assert YoTP.call(pid, :ping) == :pong

    assert YoTP.call(pid, :count) == 3
  end

  test "Step 6 - OTP - Use OTP GenServer" do

    {:ok, pid} = OTP.start

    assert GenServer.call(pid, :ping) == :pong
    assert GenServer.call(pid, :ping) == :pong
    assert GenServer.call(pid, :ping) == :pong

    assert GenServer.call(pid, :count) == 3
  end
end
