defmodule Relay.Irc.EventHandler do
  @moduledoc """
  This is an example event handler that you can attach to the client using
  `add_handler` or `add_handler_async`. To remove, call `remove_handler` or
  `remove_handler_async` with the pid of the handler process.
  """
  def start! do
    start_link([])
  end

  def start_link(client) do
    GenServer.start_link(__MODULE__, client, [])
  end

  def init(client) do
    ExIrc.Client.add_handler(client, self)

    {:ok, nil}
  end

  def handle_info({:connected, server, port}, _state) do
    debug "Connected to #{server}:#{port}"
    {:noreply, nil}
  end

  def handle_info(:logged_in, _state) do
    debug "Logged in to server"
    {:noreply, nil}
  end

  def handle_info(:disconnected, _state) do
    # debug "Disconnected from server"
    {:noreply, nil}
  end

  def handle_info({:joined, channel}, _state) do
    # debug "Joined #{channel}"
    {:noreply, nil}
  end
  # def handle_info({:received, message, sender}, _state) do
  #   from = sender.nick
  #   debug "#{from} sent us a private message: #{message}"
  #   {:noreply, nil}
  # end

  def handle_info({:received, message, sender, channel}, _state) do
    from = sender.nick
    Relay.Dispatch.dispatch(%{source: :irc, type: :message, from: from, channel: channel, message: message})

    {:noreply, nil}
  end

  # def handle_info({:mentioned, message, sender, channel}, _state) do
  #   from = sender.nick
  #   debug "#{from} mentioned us in #{channel}: #{message}"
  #   {:noreply, nil}
  # end
  def handle_info({:me, message, sender, channel}, _state) do
    from = sender.nick
    Relay.Dispatch.dispatch(%{source: :irc, type: :me, from: from, channel: channel, message: message})
    {:noreply, nil}
  end

  def handle_info(crap, _state) do
    {:noreply, nil}
  end

  defp debug(msg) do
    IO.puts IO.ANSI.yellow() <> msg <> IO.ANSI.reset()
  end
end