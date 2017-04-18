defmodule Relay.ProcessMonitor do
  use GenServer

  @moduledoc """
  Utility module for monitoring arbitrary processes and running
  a function when the monitored process dies
  """

  @doc """
  Starts the monitoring process

  Example:
     Relay.ProcessMonitor.start(self(), fn -> IO.puts("Died") end)
     {:ok, pid}
  """
  @spec start(pid, (() -> any)) :: {:ok, pid}
  def start(pid, func) do
    GenServer.start(__MODULE__, { pid, func })
  end

  @doc false
  def init({pid, func}) do
    ref = Process.monitor(pid)

    {:ok, {pid, func, ref}}
  end

  @doc false
  def handle_info({:DOWN, ref, _, _, _}, {pid, func, ref}) do
    IO.inspect(pid)
    func.()
    Process.exit(self(), :normal)
    {:noreply, nil}
  end
end