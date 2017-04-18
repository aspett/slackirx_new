defmodule Relay.Dispatch do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, [], [])
  end

  def determine_destination(from_location = %{pipeline_id: pipeline_id}) do
    pipeline = Relay.Repo.get!(Relay.Location.Pipeline, pipeline_id)

    cond do
      pipeline.source == from_location -> pipeline.destination
      pipeline.destination == from_location -> pipeline.source
      true -> nil
    end
  end

  def find_destination_pid(location) do
    Relay.Registry.Locations.find_dispatch_pid_by_location(location)
  end

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
  end

  def dispatch(location = %Relay.Location.Irc{}, dispatch_pid, event) do
    Relay.LocationService.Irc.Supervisor.dispatch(location, dispatch_pid, event)
  end

  def dispatch(location = %Relay.Location.Slack{}, dispatch_pid, event) do
    Relay.LocationService.Slack.Supervisor.dispatch(location, dispatch_pid, event)
  end

  def dispatch(input) do
    IO.inspect(input)
    { :error, :unrecognized_input }
  end
end