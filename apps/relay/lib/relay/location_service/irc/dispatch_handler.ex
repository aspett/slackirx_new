defmodule Relay.LocationService.Irc.DispatchHandler do
  use GenServer

  def start_link(client, channel) do
    GenServer.start_link(__MODULE__, { :ok, { client, channel } }, name: __MODULE__)
  end

  def init({:ok, state}) do
    {:ok, state}
  end

  def handle_cast({:message, %{from: _from, message: message}}, { client, channel }) do
    ExIrc.Client.msg(client, :privmsg, channel, message)

    { :noreply, { client, channel } }
  end

  def dispatch(dispatch = {:message, _event}) do
    GenServer.cast(__MODULE__, dispatch)
  end

  def dispatch(_) do
    {:error, :unrecognized_input}
  end
end