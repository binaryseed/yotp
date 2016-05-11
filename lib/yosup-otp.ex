defmodule Sup do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [])
  end

  def init(_) do
    [worker(YoTP.OTP, [])]
    |> supervise(strategy: :one_for_one)
  end
end
