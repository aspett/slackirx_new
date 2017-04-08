defmodule Relay.Dispatch do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, [], [])
  end

  # @spec dispatch(%{source: atom, type: atom, from: String.t, channel: String.t, message: String.t}) :: :ok | { :error, atom }
  # def dispatch(event = %{source: :slack, type: :message, channel: "***REMOVED***", from: _from, message: _message}) do
  #   IO.puts "dispatching"
  #   IO.inspect(event)

  #   Relay.LocationService.Irc.DispatchHandler.dispatch({:message, event})
  # end

  defp determine_destination(from_location = %{pipeline_id: pipeline_id}) do
    pipeline = Relay.Repo.get!(Relay.Location.Pipeline, pipeline_id)

    cond do
      pipeline.source == from_location -> pipeline.destination
      pipeline.destination == from_location -> pipeline.source
      true -> nil
    end
  end

  defp find_destination_pid(location) do
    Relay.Registry.Locations.find_dispatch_pid_by_location(location)
  end

  def dispatch(from_location, event = %{}) do
    IO.puts("Dispatch")
    IO.inspect(from_location)
    IO.inspect(event)
    IO.puts("\n")
    to_location = determine_destination(from_location)
    dispatch_pid = find_destination_pid(to_location)
    dispatch(to_location, dispatch_pid, event)
  end

  defp dispatch(location = %Relay.Location.Irc{}, dispatch_pid, event) do
    Relay.LocationService.Irc.Supervisor.dispatch(location, dispatch_pid, event)
  end

  defp dispatch(location = %Relay.Location.Slack{}, dispatch_pid, event) do
    Relay.LocationService.Slack.Supervisor.dispatch(location, dispatch_pid, event)
  end

  # def dispatch(from_location, event = %{source: :slack, type: :message, channel: "***REMOVED***", from: _from, message: _message}) do
  #   IO.puts "dispatching"
  #   IO.inspect(event)

  #   Relay.LocationService.Irc.DispatchHandler.dispatch({:message, event})
  # end

  # def dispatch(event = %{source: :irc, type: :message, from: _from, channel: _channel, message: _message}) do
  #   send :slack, { :message, event }
  # end

  # def dispatch(from_location, event = %{source: :irc, type: :message, from: _from, channel: _channel, message: _message}) do
  #   send :slack, { :message, event }
  # end

  def dispatch(input) do
    IO.inspect(input)
    { :error, :unrecognized_input }
  end
end