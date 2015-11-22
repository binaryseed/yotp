defmodule FaultToleranceTest do
  use ExUnit.Case
  import ExUnit.CaptureLog

  test "Step 1" do
    # Spawn a process
    log = capture_log(fn -> StepOne.start end)
    assert log =~ "Hello, world"
  end

  test "Step 2" do
    # Send a message back from a process
    pid = StepTwo.start(self)
    assert_receive :hey
    refute Process.alive?(pid)
  end

  test "Step 3" do
    # Start a receive loop in a process

    pid = StepThree.start

    log1 = capture_log(fn -> send(pid, :ping) end)
    assert log1 =~ "Pong!"

    log2 = capture_log(fn -> send(pid, :foo) end)
    assert log2 =~ "Bar"

    assert Process.alive?(pid)
  end

  test "Step 4" do
    # Provide a client interface

    pid = StepFour.start

    assert StepFour.call(pid, :ping) == :pong
    assert StepFour.call(pid, :foo) == :bar
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

    assert OTP.ping(pid) == :pong
    assert OTP.ping(pid) == :pong
    assert OTP.ping(pid) == :pong

    assert OTP.count(pid) == 3
  end

  test "Step 7" do
    # Start building a Supervisor

    pid = YoSup.start_link

    first_pid = YoSup.child(pid)

    Process.exit(first_pid, :blow)
    refute Process.alive? first_pid

    second_pid = YoSup.child(pid)
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









