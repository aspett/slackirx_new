defmodule Relay.Slack do
  use Slack

  def handle_connect(slack, state) do
    IO.puts("Connected as #{slack.me.name}")

    { :ok, state }
  end

  # Swallow downstream errors, otherwise the websocket application breaks too
  # and that's pretty rubbish in my opinion.
  def handle_event(event, slack, state) do
    try do
      handle(event, slack, state)
    catch
      _ -> nil
    end

    { :ok, state }
  end

  def handle(event = %{type: "message"}, slack, state) do
    from = lookup_user_name(event.user, slack)
    channel = lookup_channel_name(event.channel, slack)
    message = event.text

    Relay.Dispatch.dispatch(%{source: :slack, type: :message, from: from, channel: channel, message: message})

    { :ok, state }
  end

  def handle(crap, _, state) do
    IO.puts "catchall"
    IO.inspect(crap)
    { :ok, state }
  end

  def handle_info({ :message, %{from: from, message: message}}, slack, state) do
    channel_id = lookup_channel_id("***REMOVED***", slack)
    send_message("#{from}: #{message}", channel_id, slack)

    {:ok, state}
  end

  def handle_info(info, _slack, state) do
    IO.puts("\nSlack Info")
    IO.inspect(info)

    { :ok, state }
  end
end