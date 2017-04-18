defmodule Relay.Dispatch do
  use GenServer

  @type event    :: %{source: atom, type: atom, from: String.t, channel: String.t, message: String.t}

  @moduledoc """
  The module responsible for routing incoming messages to outgoing dispatchers
  """

  @doc "Starts the dispatch process"
  @spec start_link() :: {:ok, pid}
  def start_link do
    GenServer.start_link(__MODULE__, [], [])
  end

  @doc """
  Given a source location, finds the detination location for the message based off
  the source location's pipeline
  """
  @spec determine_destination(Relay.Location.t) :: Relay.Location.t | nil
  def determine_destination(from_location)
  def determine_destination(from_location = %{pipeline_id: pipeline_id}) do
    pipeline = Relay.Repo.get!(Relay.Location.Pipeline, pipeline_id)

    cond do
      pipeline.source == from_location -> pipeline.destination
      pipeline.destination == from_location -> pipeline.source
      true -> nil
    end
  end

  @doc """
  Finds a location's dispatch pid
  """
  @spec find_destination_pid(Relay.Location.t) :: pid
  def find_destination_pid(location) do
    Relay.Registry.Locations.find_dispatch_pid_by_location(location)
  end

  @doc """
  The main function of this module; takes a source location and event, and dispatches it to a destination
  """
  @spec dispatch(Relay.Location.t, event) :: :ok
  def dispatch(from_location, event)
  def dispatch(from_location, event = %{}) do
    IO.puts("Dispatch start")
    IO.inspect(from_location)
    IO.inspect(event)
    IO.puts("\n")
    to_location = determine_destination(from_location)
    dispatch_pid = find_destination_pid(to_location)
    IO.puts("to_location")
    IO.inspect(to_location)
    IO.puts("dispatch_pid")
    IO.inspect(dispatch_pid)
    IO.puts("\n===========================")
    dispatch(to_location, dispatch_pid, event)
    :ok
  end

  @doc "Dispatches an event to an IRC location. See `#{__MODULE__}.dispatch/2`"
  @spec dispatch(%Relay.Location.Irc{}, pid, event) :: :ok | { :error, atom }
  def dispatch(location, dispatch_pid, event)
  def dispatch(location = %Relay.Location.Irc{}, dispatch_pid, event) do
    Relay.LocationService.Irc.Supervisor.dispatch(location, dispatch_pid, event)
  end

  @doc "Dispatches an event to a Slack location. See `#{__MODULE__}.dispatch/2`"
  @spec dispatch(%Relay.Location.Slack{}, pid, event) :: :ok | { :error, atom }
  def dispatch(location = %Relay.Location.Slack{}, dispatch_pid, event) do
    Relay.LocationService.Slack.Supervisor.dispatch(location, dispatch_pid, event)
  end
end