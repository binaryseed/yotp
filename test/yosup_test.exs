defmodule YoSupTest do
  use ExUnit.Case

  test "YoSup 1 - Link a process" do

    pid = spawn(fn ->
      spawn_link(fn ->
        Not.a_function
      end)
    end)

    :timer.sleep(10)
    refute Process.alive?(pid)
  end

  test "YoSup 2 - Trap exits" do

    pid = spawn(fn ->
      Process.flag :trap_exit, true
      spawn_link(fn ->
        AlsoNot.a_function
      end)
      receive do
        {:EXIT, _pid, _reason}=msg ->
          IO.puts "Caught #{inspect msg}"
      end
    end)

    :timer.sleep(10)
    assert Process.alive?(pid)
  end

  test "YoSup 3 - specify a child" do

    spec = {OTP, []}
    pid = YoSup.StepThree.start(spec)

    child = YoSup.StepThree.child(pid)

    assert Process.alive?(pid)
    assert Process.alive?(child)

    assert GenServer.call(child, :ping) == :pong
  end

  test "Step 7 - YoSup - restart child when it dies" do

    pid = YoSup.start_link

    first_pid = YoSup.child(pid)
    Process.exit(first_pid, :blow)
    refute Process.alive? first_pid

    second_pid = YoSup.child(pid)
    assert Process.alive? second_pid

    refute first_pid == second_pid
  end

  test "Step 8 - Sup -> Real OTP Supervisor" do
    {:ok, pid} = Sup.start_link

    [{_, first_pid, _, _}] = Supervisor.which_children(pid)
    Process.exit(first_pid, :blow)
    refute Process.alive? first_pid

    [{_, second_pid, _, _}] = Supervisor.which_children(pid)
    assert Process.alive? second_pid

    refute first_pid == second_pid
  end
end
