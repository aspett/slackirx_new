defmodule Relay.Dispatch do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, [], [])
  end

  @spec dispatch(%{source: atom, type: atom, from: String.t, channel: String.t, message: String.t}) :: :ok | { :error, atom }
  def dispatch(event = %{source: :slack, type: :message, channel: "***REMOVED***", from: _from, message: _message}) do
    IO.puts "dispatching"
    IO.inspect(event)

    Relay.LocationService.Irc.DispatchHandler.dispatch({:message, event})
  end

  def dispatch(event = %{source: :irc, type: :message, from: _from, channel: _channel, message: _message}) do
    send :slack, { :message, event }
  end

  def dispatch(input) do
    IO.inspect(input)
    { :error, :unrecognized_input }
  end
end