defmodule Relay.LocationService.Irc.EventHandler do
  @moduledoc """
  This module handles events originating from an IRC client, and passes them to the dispatcher
  """

  @doc "Starts the process"
  @spec start_link(pid(), %Relay.Location.Irc{} | %Relay.Location.Slack{}, list(any())) :: {:ok, pid()}
  def start_link(client, location, opts \\ []) do
    GenServer.start_link(__MODULE__, { client, location }, opts)
  end

  @doc false
  @spec init({ pid, Relay.Location.t }) :: {:ok, Relay.Location.t }
  def init({ client, location }) do
    ExIrc.Client.add_handler(client, self())

    {:ok, location}
  end

  @doc false
  def handle_info({:connected, server, port}, location) do
    debug "Connected to #{server}:#{port}"
    {:noreply, location}
  end

  @doc false
  def handle_info(:logged_in, location) do
    debug "Logged in to server"
    {:noreply, location}
  end

  @doc false
  def handle_info(:disconnected, location) do
    {:noreply, location}
  end

  @doc false
  def handle_info({:joined, _channel}, location) do
    {:noreply, location}
  end

  @doc false
  def handle_info({:received, message, sender, channel}, location = %{channel: location_channel}) when channel == location_channel do
    from = sender.nick
    Relay.Dispatch.dispatch(location, %{source: :irc, type: :message, from: from, channel: channel, message: message})

    {:noreply, location}
  end

  @doc false
  def handle_info({:me, message, sender, channel}, location) do
    from = sender.nick
    Relay.Dispatch.dispatch(location, %{source: :irc, type: :me, from: from, channel: channel, message: message})
    {:noreply, location}
  end

  @doc false
  def handle_info(_crap, location) do
    {:noreply, location}
  end

  defp debug(msg) do
    IO.puts IO.ANSI.yellow() <> msg <> IO.ANSI.reset()
  end
end