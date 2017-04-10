defmodule Relay.ProcessMonitor do
  use GenServer

  def start(pid, func) do
    GenServer.start(__MODULE__, { pid, func })
  end

  def init({pid, func}) do
    ref = Process.monitor(pid)

    {:ok, {pid, func, ref}}
  end

  def handle_info({:DOWN, ref, _, _, _}, {pid, func, ref}) do
    IO.inspect(pid)
    func.()
    Process.exit(self(), :normal)
    {:noreply, nil}
  end
end