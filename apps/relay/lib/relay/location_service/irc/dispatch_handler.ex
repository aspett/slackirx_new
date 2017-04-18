defmodule Relay.LocationService.Irc.DispatchHandler do
  use GenServer

  @moduledoc """
  Handles dispatching messages to IRC
  """

  @doc "Starts the process"
  @spec start_link(pid(), String.t, list(any())) :: {:ok, pid}
  def start_link(client, channel, opts \\ []) do
    GenServer.start_link(__MODULE__, { :ok, { client, channel } }, opts)
  end

  @doc false
  @spec init({:ok, { pid, String.t }}) :: {:ok, {pid, String.t}}
  def init({:ok, state}) do
    {:ok, state}
  end

  def handle_cast({:message, %{from: _from, message: message}}, { client, channel }) do
    ExIrc.Client.msg(client, :privmsg, channel, message)

    { :noreply, { client, channel } }
  end

  @doc """
  Dispatch a message to the DispatchHandler with pid `pid`

  Example:
      iex> Relay.LocationService.Irc.DispatchHandler.dispatch(pid("0.0.0"), {:message, %{}})
      :ok
  """
  @spec dispatch(pid(), {:message, %{source: atom, type: atom, from: String.t, channel: String.t, message: String.t}}) :: :ok
  def dispatch(pid, dispatch = {:message, _event}) do
    GenServer.cast(pid, dispatch)
  end
end