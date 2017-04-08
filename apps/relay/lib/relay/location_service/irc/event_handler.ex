defmodule Relay.LocationService.Irc.EventHandler do
  @moduledoc """
  This is an example event handler that you can attach to the client using
  `add_handler` or `add_handler_async`. To remove, call `remove_handler` or
  `remove_handler_async` with the pid of the handler process.
  """
  # def start! do
  #   start_link([])
  # end

  def start_link(client, location) do
    GenServer.start_link(__MODULE__, { client, location }, [])
  end

  def init({ client, location }) do
    ExIrc.Client.add_handler(client, self())

    {:ok, location}
  end

  def handle_info({:connected, server, port}, location) do
    debug "Connected to #{server}:#{port}"
    {:noreply, location}
  end

  def handle_info(:logged_in, location) do
    debug "Logged in to server"
    {:noreply, location}
  end

  def handle_info(:disconnected, location) do
    # debug "Disconnected from server"
    {:noreply, location}
  end

  def handle_info({:joined, _channel}, location) do
    # debug "Joined #{channel}"
    {:noreply, location}
  end
  # def handle_info({:received, message, sender}, _state) do
  #   from = sender.nickk
  #   debug "#{from} sent us a private message: #{message}"
  #   {:noreply, nil}
  # end

  def handle_info({:received, message, sender, channel}, location = %{channel: location_channel}) when channel == location_channel do
    from = sender.nick
    Relay.Dispatch.dispatch(location, %{source: :irc, type: :message, from: from, channel: channel, message: message})

    {:noreply, location}
  end

  # def handle_info({:mentioned, message, sender, channel}, _state) do
  #   from = sender.nick
  #   debug "#{from} mentioned us in #{channel}: #{message}"
  #   {:noreply, nil}
  # end
  def handle_info({:me, message, sender, channel}, location) do
    from = sender.nick
    Relay.Dispatch.dispatch(%{source: :irc, type: :me, from: from, channel: channel, message: message})
    {:noreply, location}
  end

  def handle_info(_crap, location) do
    {:noreply, location}
  end

  defp debug(msg) do
    IO.puts IO.ANSI.yellow() <> msg <> IO.ANSI.reset()
  end
end