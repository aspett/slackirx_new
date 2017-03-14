defmodule Relay.Dispatch do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, [], [])
  end

  @spec dispatch(%{source: atom, type: atom, from: String.t, channel: String.t, message: String.t}) :: :ok | { :error, atom }
  def dispatch(event = %{source: :slack, type: :message, channel: "***REMOVED***", from: from, message: message}) do
    IO.puts "dispatching"
    IO.inspect(event)
    Relay.Irc.DispatchHandler.dispatch({:message, event})
    :ok
  end

  def dispatch(event = %{source: :irc, type: :message, from: from, channel: channel, message: message}) do
    send :slack, { :message, event }
  end

  def dispatch(input) do
    IO.inspect(input)
    { :error, :unrecognized_input }
  end
end