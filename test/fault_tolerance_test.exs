defmodule FaultToleranceTest do
  use ExUnit.Case
  import ExUnit.CaptureLog
  require Logger

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

  test "Step 4" do
    # Provide a client interface

    pid = StepFour.start

    assert StepFour.call(pid, :ping) == :pong
    assert StepFour.call(pid, :foo) == :bar
  end

  test "Step 4.5" do
    # Add state to the process

    pid = StepFourPointFive.start

    assert StepFourPointFive.call(pid, :ping) == {:pong, 1}
    assert StepFourPointFive.call(pid, :PING) == {:PONG, 11}
    assert StepFourPointFive.call(pid, :ping) == {:pong, 12}
  end

  test "Step 5 - YoTP" do
    # Add callbacks to generalize

    pid = YoTP.start

    assert YoTP.call(pid, :ping) == :pong
    assert YoTP.call(pid, :ping) == :pong
    assert YoTP.call(pid, :ping) == :pong

    assert YoTP.call(pid, :count) == 3
  end

  test "Step 6 - OTP" do
    # Move to the full GenServer

    {:ok, pid} = OTP.start

    assert GenServer.call(pid, :ping) == :pong
    assert GenServer.call(pid, :ping) == :pong
    assert GenServer.call(pid, :ping) == :pong

    assert GenServer.call(pid, :count) == 3
  end

  test "Step 7 - YoSup" do
    # a Supervisor

    pid = YoSup.start_link

    first_pid = YoSup.child(pid)
    Process.exit(first_pid, :blow)
    refute Process.alive? first_pid

    second_pid = YoSup.child(pid)
    assert Process.alive? second_pid

    refute first_pid == second_pid
  end

  test "Step 8 - Sup" do
    # Use OTP Supervisor

    {:ok, pid} = Sup.start_link

    [{_, first_pid, _, _}] = Supervisor.which_children(pid)
    Process.exit(first_pid, :blow)
    refute Process.alive? first_pid

    [{_, second_pid, _, _}] = Supervisor.which_children(pid)
    assert Process.alive? second_pid

    refute first_pid == second_pid
  end
end

#
# * Concurrent Processes
# * Strong Isolation
# * Message Passing
# * Fail Fast
#









