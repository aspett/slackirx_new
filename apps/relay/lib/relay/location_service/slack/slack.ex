defmodule Relay.LocationService.Slack do
  use Slack

  @type slack_map :: map
  @type state     :: map

  @moduledoc """
  Implementation of Slack.Bot. Should be started using Slack.Bot, not directly.
  See [https://github.com/BlakeWilliams/Elixir-Slack]()
  """

  @doc false
  def handle_connect(slack, state) do
    IO.puts("Connected as #{slack.me.name}")

    { :ok, state }
  end

  # Swallow downstream errors, otherwise the websocket application breaks too
  # and that's pretty rubbish in my opinion.
  @doc false
  def handle_event(event, slack, state) do
    try do
      handle(event, slack, state)
    catch
      _ -> nil
    end

    { :ok, state }
  end

  @doc false
  def handle_close(_, _, state) do
    { :ok, state }
  end

  @doc """
  Handle a message coming from Slack, and send it to the dispatcher
  """
  @spec handle(Relay.Dispatch.event, slack_map, state) :: {:ok, state}
  def handle(event, slack, state)
  def handle(event = %{type: "message"}, slack, state) do
    from = lookup_user_name(event.user, slack)
    channel = lookup_channel_name(event.channel, slack)
    message = event.text
    { location, _, _ } = Relay.Registry.Locations.find_by_location_pid(self())

    if channel == location.channel do
      Relay.Dispatch.dispatch(location, %{source: :slack, type: :message, from: from, channel: channel, message: message})
    end

    { :ok, state }
  end

  def handle(_crap, _, state) do
    { :ok, state }
  end

  @doc false
  def handle_info(message, slack, state)
  def handle_info({ :message, %{from: from, message: message}}, slack, state) do
    { location, _, _ } = Relay.Registry.Locations.find_by_location_pid(self())
    channel_id = lookup_channel_id(location.channel, slack)
    send_message("#{from}: #{message}", channel_id, slack)

    {:ok, state}
  end

  def handle_info({ :start_monitor, supervisor_pid }, _slack, state) when is_pid(supervisor_pid) do
    IO.puts("Starting slack monitor")

    Relay.ProcessMonitor.start(self(), fn ->
      IO.puts("Killing supervisor_pid")
      IO.inspect(supervisor_pid)
      Process.exit(supervisor_pid, :kill)
    end)

    {:ok, state}
  end

  def handle_info(info, _slack, state) do
    IO.puts("\nSlack Info")
    IO.inspect(info)

    { :ok, state }
  end
end